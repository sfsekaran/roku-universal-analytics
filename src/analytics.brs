' ********************************************************************
' ********************************************************************
' **
' **  Roku Universal Analytics Tracking Library (BrightScript)' **
' **  v. 0.1
' **
' **  @author David Vallejo <thyngster@gmail.com> ( @thyng )
' **  Copyright 2013
' **
' ********************************************************************
' ********************************************************************

Function GenerateGuid() As String
    Return "" + GetRandomHexString(8) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(12) + ""
End Function

Function GetRandomHexString(length As Integer) As String
    hexChars = "0123456789ABCDEF"
    hexString = ""
    For i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    Next
    Return hexString
End Function

Function GetRandomInt(length As Integer) As String
    hexChars = "0123456789"
    hexString = ""
    For i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    Next
    Return hexString
End Function

Function GetUserID()
    sec = CreateObject("roRegistrySection", "analytics")
    if sec.Exists("UserID")
        return sec.Read("UserID")
    endif
    return invalid
End Function

Function SetUserID() As String
    sec = CreateObject("roRegistrySection", "analytics")
    uuid = GenerateGuid()
    sec.Write("UserID", uuid)
    sec.Flush()
    Return uuid
End Function

Function UA_Init(AccountID) as Void
    di = CreateObject("roDeviceInfo") 
    m.UATracker = CreateObject("roAssociativeArray")

    m.UATracker.userID = GetUserID()
    m.UATracker.AccountID = AccountID

    if m.UATracker.userID = invalid then
        m.UATracker.userID = SetUserID()
    endif

    m.UATracker.model = di.GetModel()
    m.UATracker.version = di.GetVersion()    
    
    'dimensiones = di.GetDisplaySize()
    'm.UATracker.display = dimensiones.w + "x" + dimensiones.h

    if di.GetDisplayMode() = "480i"
    m.UATracker.display = "704x480"
    elseif di.GetDisplayMode() = "720p"
    m.UATracker.display = "1280x720"
    else
    m.UATracker.display = "0x0"
    end if

    m.UATracker.appName = "Test_APP"
    m.UATracker.appVersion = "b1"
    m.UATracker.companyName = "CompanyName"

    m.UATracker.ratio = di.GetDisplayAspectRatio()
    ' m.UATracker.endpoint = "http://requestb.in/1ikqvlt1"
    m.UATracker.endpoint = "http://www.google-analytics.com/collect"
End Function

Function UA_trackEvent(EventCategory, EventAction, EventLabel = invalid, EventValue = invalid) as Void
  params = {
    t: "event",
    ec: EventCategory,
    ea: EventAction
  }

  If EventLabel <> invalid
    params.el = EventLabel
  end if
  If EventValue <> invalid
    params.ev = EventValue
  end if

  UA_sendRequest(params)
End Function

Function UA_trackPageview(Pageview) as Void
  params = {
    t: "pageview",
    dp: Pageview
  }

  UA_sendRequest(params)
End Function

Function UA_trackScreen(ScreenName) as Void
  params = {
    t: "screenview", '&t=screenview // Screenview hit type.
    aid: "com." + m.UATracker.companyName + ".RokuApp", '&aid=com.foo.App // App Id.
    aiid: "com.Roku.Store", '&aiid=com.android.vending // App Installer Id.
    cd: ScreenName ' &cd=Home // Screen name / content description.
  }

  print "UA_trackScreen:"
  print params

  UA_sendRequest(params)
end Function

Function UA_sendRequest(params)
  xfer = CreateObject("roURLTransfer")

  ' these parameters go out with every request
  params.v = "1" 'v=1 // Version.
  params.tid = m.UATracker.AccountID '&tid=UA-XXXX-Y // Tracking ID / Web property / Property ID.
  params.cid = m.UATracker.userID '&cid=555 // Anonymous Client ID, UUID v4 format.
  params.an = m.UATracker.appName
  params.av = m.UATracker.appVersion
  params.sr = m.UATracker.display
  params.sd = m.UATracker.ratio
  params.dimension1 = m.UATracker.model
  params.dimension2 = m.UATracker.version
  params.z = GetRandomInt(100) ' google recommends placing this last

  ' urlencode each parameter
  payload = ""
  for each key in params
    if payload <> ""
      payload = payload + "&"
    end if
    payload = payload + key + "=" + xfer.Escape(params[key])
  end for

  ' bombs away
  url = m.UATracker.endpoint + "?" + payload
  xfer.SetURL(url)
  print "UA_sendRequest: " + url
  response = xfer.GetToString()
end Function