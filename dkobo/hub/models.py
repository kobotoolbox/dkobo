from django.db import models
from markitup.fields import MarkupField
from django.contrib.sites.models import Site

class SitewideMessage(models.Model):
    slug = models.CharField(max_length=50)
    body = MarkupField()
    site = models.ForeignKey(Site, null=True)

    def __str__(self):
        return self.slug