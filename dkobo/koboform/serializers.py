from rest_framework import serializers
from models import SurveyDraft
from taggit.models import Tag

class ListSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'asset_type', 'summary', 'date_modified', 'description')
        exclude = ('asset_type', )

class DetailSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):
    tags = serializers.SerializerMethodField('get_tag_names')
    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'body', 'summary', 'date_modified', 'description', 'tags')
        exclude = ('asset_type', )

    def get_tag_names(self, obj):
        return obj.tags.names()

class TagSerializer(serializers.HyperlinkedModelSerializer):
    count = serializers.SerializerMethodField('get_count')
    label = serializers.WritableField('name')
    class Meta:
        model = Tag
        fields = ('id', 'label', 'count')

    def get_count(self, obj):
        return SurveyDraft.objects.filter(tags__name__in=[obj.name])\
            .filter(user=self.context.get('request', None).user)\
            .filter(asset_type='question')\
            .count()