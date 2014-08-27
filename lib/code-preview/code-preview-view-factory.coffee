global.previewView = null

exports.getPreviewView = ->
  global.PreviewView ?= require './code-preview-view'
  return global.PreviewView
