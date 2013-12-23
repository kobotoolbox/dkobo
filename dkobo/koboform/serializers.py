from rest_framework import serializers
from models import SurveyDraft


class SurveyDraftSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = SurveyDraft
        fields = ('id', 'name', 'body', 'description')
