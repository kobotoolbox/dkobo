from rest_framework import serializers
from models import SurveyDraft
from taggit.models import Tag

class WritableJSONField(serializers.Field):

    """ Serializer for JSONField -- required to make field writable"""
    """ ALSO REQUIRED because the default JSONField serialization includes the
    `u` prefix on strings when running Django 1.8, resulting in invalid JSON
    """

    def __init__(self, **kwargs):
        self.allow_blank= kwargs.pop('allow_blank', False)
        super(WritableJSONField, self).__init__(**kwargs)

    def to_internal_value(self, data):
        if (not data) and (not self.required):
            return None
        else:
            try:
                return json.loads(data)
            except Exception as e:
                raise serializers.ValidationError(
                    u'Unable to parse JSON: {}'.format(e))

    def to_representation(self, value):
        return value


class ListSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'asset_type', 'summary', 'date_modified', 'description')

    summary = WritableJSONField(required=False)

class DetailSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):
    tags = serializers.SerializerMethodField('get_tag_names')
    summary = WritableJSONField(required=False)

    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'body', 'summary', 'date_modified', 'description', 'tags')

    def get_tag_names(self, obj):
        return obj.tags.names()


class TagSerializer(serializers.HyperlinkedModelSerializer):
    count = serializers.SerializerMethodField()
    label = serializers.CharField(source='name')
    class Meta:
        model = Tag
        fields = ('id', 'label', 'count')

    def get_count(self, obj):
        return SurveyDraft.objects.filter(tags__name__in=[obj.name])\
            .filter(user=self.context.get('request', None).user)\
            .filter(asset_type='question')\
            .count()
