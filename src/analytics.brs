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

Function UA_trackEvent(EventCat, EventAct, EventLab, EventVal) as Void
  params = {
    z: "" + GetRandomInt(10),
    v: "1",
    cid: m.UATracker.userID,
    tid: m.UATracker.AccountID,
    dimension1: m.UATracker.model,
    dimension2: m.UATracker.version,
    sr: m.UATracker.display,
    sd: m.UATracker.ratio,
    an: m.UATracker.appName,
    av: m.UATracker.appVersion,

    t: "event"
  }

  If EventCat <> invalid
    params.ec = EventCat
  end if
  If EventAct <> invalid
    params.ea = EventAct
  end if
  If EventLab <> invalid
    params.el = EventLab
  end if
  If EventVal <> invalid
    params.ev = EventVal
  end if

  UA_sendRequest(params)
End Function

Function UA_trackPageview(Pageview) as Void
  params = {
    z: "" + GetRandomInt(10),
    v: "1",
    cid: m.UATracker.userID,
    tid: m.UATracker.AccountID,
    dimension1: m.UATracker.model,
    dimension2: m.UATracker.version,
    sr: m.UATracker.display,
    sd: m.UATracker.ratio,
    an: m.UATracker.appName,
    av: m.UATracker.appVersion,
    t: "pageview",

    dp: Pageview
  }

  UA_sendRequest(params)
End Function

Function UA_trackScreen(ScreenName) as Void
  params = {
    v: m.UATracker.appVersion, 'v=1 // Version.
    tid: m.UATracker.AccountID, '&tid=UA-XXXX-Y // Tracking ID / Web property / Property ID.
    cid: m.UATracker.userID, '&cid=555 // Anonymous Client ID.

    t: "screenview", '&t=screenview // Screenview hit type.
    an: m.UATracker.appName, '&an=funTimes // App name.
    av: m.UATracker.appVersion, '&av=4.2.0 // App version.
    aid: "com." + m.UATracker.companyName + ".RokuApp", '&aid=com.foo.App // App Id.
    aiid: "com.Roku.Store", '&aiid=com.android.vending // App Installer Id.

    cd: ScreenName ' &cd=Home // Screen name / content description.
  }

  UA_sendRequest(params)
end Function

Function UA_sendRequest(params)
  xfer = CreateObject("roURLTransfer")

  payload = ""
  for each key in params
    if payload <> ""
      payload = payload + "&"
    end if
    payload = payload + key + "=" + xfer.Escape(params[key])
  end for

  xfer.SetURL(m.UATracker.endpoint + "?" + payload)
  response = xfer.GetToString()
end Function