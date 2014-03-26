from rest_framework import viewsets
from rest_framework.decorators import action
from django.core.exceptions import PermissionDenied
from rest_framework.response import Response
from models import SurveyDraft, SurveyPreview
from serializers import ListSurveyDraftSerializer, DetailSurveyDraftSerializer
from django.shortcuts import render_to_response, HttpResponse, get_object_or_404

class SurveyAssetViewset(viewsets.ModelViewSet):
    model = SurveyDraft
    serializer_class = ListSurveyDraftSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_anonymous():
            raise PermissionDenied
        return SurveyDraft.objects.filter(user=user)

    def create(self, request):
        user = self.request.user
        if user.is_anonymous():
            raise PermissionDenied
        contents = request.POST
        survey_draft = request.user.survey_drafts.create(**contents)
        return Response(ListSurveyDraftSerializer(survey_draft).data)

    def retrieve(self, request, pk=None):
        user = request.user
        queryset = SurveyDraft.objects.filter(user=user)
        survey_draft = get_object_or_404(queryset, pk=pk)
        return Response(DetailSurveyDraftSerializer(survey_draft).data)

    @action(methods=['DELETE'])
    def delete_survey_draft(self, request, pk=None):
        draft = self.get_object()
        draft.delete()

class LibraryAssetViewset(SurveyAssetViewset):
    def get_queryset(self):
        user = self.request.user
        if user.is_anonymous():
            raise PermissionDenied
        return SurveyDraft.objects.filter(user=user).exclude(asset_type=None)

class SurveyDraftViewSet(SurveyAssetViewset):
    def get_queryset(self):
        user = self.request.user
        if user.is_anonymous():
            raise PermissionDenied
        return SurveyDraft.objects.filter(user=user)
