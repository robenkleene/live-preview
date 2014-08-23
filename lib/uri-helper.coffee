url = require 'url'

exports.protocolForUri = (uri) ->
  try
    {protocol} = url.parse(uri)
  catch error
    console.error error
    return
  return protocol

exports.uriForEditorId = (protocol, editorId) ->
  "#{protocol}//editor/#{editorId}"

exports.editorIdForUri = (aProtocol, uri) ->
  try
    {protocol, host, pathname} = url.parse(uri)
  catch error
    console.error error
    return

  return unless protocol is aProtocol
  return unless host is 'editor'

  try
    pathname = decodeURI(pathname) if pathname
  catch error
    console.error error
    return

  return pathname.substring(1)
