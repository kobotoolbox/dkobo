"""
Mostly copied from django/contrib/admin/actions.py
"""

from collections import OrderedDict, defaultdict
from django.core.exceptions import PermissionDenied
from django.contrib import messages
from django.contrib.admin import helpers
from django.contrib.admin.util import get_deleted_objects, model_ngettext
from django.contrib.admin.util import NestedObjects
from django.db import router, transaction
from django.template.response import TemplateResponse
from django.utils.encoding import force_text
from django.utils.translation import ugettext_lazy, ugettext as _

def delete_related_objects(modeladmin, request, queryset):
    """
    Action that deletes related objects for the selected items.

    This action first displays a confirmation page whichs shows all the
    deleteable objects, or, if the user has no permission one of the related
    childs (foreignkeys), a "permission denied" message.

    Next, it deletes all related objects and redirects back to the change list.
    """
    opts = modeladmin.model._meta
    app_label = opts.app_label

    # Check that the user has delete permission for the actual model
    if not modeladmin.has_delete_permission(request):
        raise PermissionDenied

    using = router.db_for_write(modeladmin.model)

    first_level_related_objects = []
    first_level_related_objects_by_type = defaultdict(list)
    collector = NestedObjects(using=using)
    collector.collect(queryset)
    for base_object_or_related_list in collector.nested():
        if type(base_object_or_related_list) is not list:
            # If it's not a list, it's a base object. Skip it.
            continue
        for obj in base_object_or_related_list:
            if type(obj) is list:
                # A list here contains related objects for the previous
                # element. We can skip it since delete() on the first
                # level of related objects will cascade.
                continue
            else:
                first_level_related_objects.append(obj)
                first_level_related_objects_by_type[type(obj)].append(obj)

    deletable_objects = []
    model_count = defaultdict(int)
    perms_needed = set()
    protected = []
    # `get_deleted_objects()` fails when passed a heterogeneous list like
    # `first_level_related_objects`, so embark on this rigmarole to spoon-feed
    # it only homogeneous lists
    for homogeneous_list in first_level_related_objects_by_type.values():
        # Populate deletable_objects, a data structure of (string
        # representations of) all related objects that will also be deleted.
        deletable_objects_, model_count_, perms_needed_, protected_ = get_deleted_objects(
            homogeneous_list, opts, request.user, modeladmin.admin_site, using)
        # Combine the results with those from previous homogeneous lists
        deletable_objects.extend(deletable_objects_)
        for k, v in model_count_.iteritems():
            model_count[k] += v
        perms_needed.update(perms_needed_)
        protected.extend(protected_)

    # The user has already confirmed the deletion.
    # Do the deletion and return a None to display the change list view again.
    if request.POST.get('post'):
        if perms_needed:
            raise PermissionDenied
        n = 0
        with transaction.atomic(using):
            for obj in first_level_related_objects:
                obj_display = force_text(obj)
                modeladmin.log_deletion(request, obj, obj_display)
                obj.delete()
                n += 1
        modeladmin.message_user(
            request,
            _("Successfully deleted %(count)d related objects.") % {
                "count": n, "items": model_ngettext(modeladmin.opts, n)},
            messages.SUCCESS
        )
        # Return None to display the change list page again.
        return None

    if len(queryset) == 1:
        objects_name = force_text(opts.verbose_name)
    else:
        objects_name = force_text(opts.verbose_name_plural)

    if perms_needed or protected:
        title = _("Cannot delete %(name)s") % {"name": objects_name}
    else:
        title = _("Are you sure?")

    context = dict(
        modeladmin.admin_site.each_context(request),
        title=title,
        objects_name=objects_name,
        deletable_objects=[deletable_objects],
        model_count=dict(model_count).items(),
        queryset=queryset,
        perms_lacking=perms_needed,
        protected=protected,
        opts=opts,
        action_checkbox_name=helpers.ACTION_CHECKBOX_NAME,
    )

    request.current_app = modeladmin.admin_site.name

    # Display the confirmation page
    return TemplateResponse(
        request, "delete_related_for_selected_confirmation.html",
        context, current_app=modeladmin.admin_site.name)

delete_related_objects.short_description = ugettext_lazy(
    "Remove related objects for these %(verbose_name_plural)s")
