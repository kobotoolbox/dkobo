# -*- coding: utf-8 -*-
from south.utils import datetime_utils as datetime
from south.db import db
from south.v2 import DataMigration
from django.db import models
from django.core import management

class Migration(DataMigration):

    def forwards(self, orm):
        management.call_command("populate_summary_field")

    def backwards(self, orm):
        pass

    complete_apps = ['koboform']
    symmetrical = True
