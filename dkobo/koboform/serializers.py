from rest_framework import serializers
from models import SurveyDraft

class ListSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'asset_type', 'description', 'date_modified')

class DetailSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'body', 'description', 'date_modified')
