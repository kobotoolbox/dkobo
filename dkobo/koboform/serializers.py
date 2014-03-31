from rest_framework import serializers
from models import SurveyDraft

class ListSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'asset_type', 'summary', 'date_modified')
        exclude = ('asset_type', )

class DetailSurveyDraftSerializer(serializers.HyperlinkedModelSerializer):

    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'body', 'summary', 'date_modified')
        exclude = ('asset_type', )
