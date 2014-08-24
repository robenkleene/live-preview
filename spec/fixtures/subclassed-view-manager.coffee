LivePreviewViewManager = require '../../lib/live-preview-view-manager'

module.exports =
class SubclassedViewManager extends LivePreviewViewManager
  resolvePreviewView: =>
    @PreviewView ?= require './subclassed-view'
