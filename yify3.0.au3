#include "WinHttp.au3"
#include "_XMLDomWrapper.au3"
;#include <_StringStripChr.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <Excel.au3>
#include <File.au3>

#Include <GuiTab.au3>
#Include <GuiListBox.au3>
#include <GuiTreeView.au3>
#Include <GuiListView.au3>
#include <Date.au3>
#include <ListBoxConstants.au3>

; Setting Standard Varibles for the Website
Global $sDomain = "yts.re" ; Sets website
Global $Quality = "720p"
Global $Quality1 = "1080p"
Global $Quality2 = "480p"
Global $Quality3 = "DVD"
Global $Quality4 = "HDRip"
Global $sPage = "/api/list.xml" ;Sets api call (page on the site)
;Global $setCount = 1 ; sets page number
;MsgBox(1,"is this working","maybe")
$FirstRunData720p = Grabwebdata($sDomain,$sPage,$Quality,1)
;MsgBox(1,"test", $FirstRunData720p)
$Varibles720p = ReadwebData($FirstRunData720p)
;_ArrayDisplay($Varibles720p)
$Array720p = parsedCreate($Varibles720p,$Quality)

$FirstRunData1080p = Grabwebdata($sDomain,$sPage,$Quality1,1)
;MsgBox(1,"test",$FirstRunData1080p)
$Varibles1080p = ReadwebData($FirstRunData1080p)
;_ArrayDisplay($Varibles1080p)
$Array1080p = parsedCreate($Varibles1080p,$Quality1)



;_ArrayDisplay($Array720p)
;_ArrayDisplay($Array1080p)

$count = 0
For $o = 0 to UBound($Array720p) - 1 ; this group of functions looks for duplicates 720 vs 1080
   $searchMATCH = _ArraySearch($Array1080p, $Array720p[$o][0], 0, 0, 0, 1)
   if @error Then 
	  $count += 1
	  ;MsgBox(1,"Not Found",$Array720p[$o][0])
	  ;$download720pcsv =+ $Array720p[$o][0] & "," & $Array720p[$o][1] & @CRLF
   Else
	  ;MsgBox(1,"seach value",$Array720p[$o][0])
   EndIf
Next
;MsgBox(1,"test v csv",  $count)
;MsgBox(1,"test v csv",  $download720pcsv)

global $download720[$count][2]
$p = 0
For $o = 0 to UBound($Array720p) - 1 ; this group of functions looks for duplicates 720 vs 1080
   $searchMATCH = _ArraySearch($Array1080p, $Array720p[$o][0], 0, 0, 0, 1)
   if @error Then 
	  $p += 1
	  ;MsgBox(1,"Not Found",$Array720p[$o][0])
	  $download720[$p - 1][0] = $Array720p[$o][0]
	  $download720[$p - 1][1] = $Array720p[$o][1]
	  
	  ;_ArrayDisplay($download720)
   Else
	  ;MsgBox(1,"seach value",$Array720p[$o][0])
   EndIf
Next
;_ArrayDisplay($download720)

$array1080count = UBound($Array1080p) - 1
$array720count = UBound($download720) - 1
$totalcount = $array1080count + $array720count

MsgBox(1, "720 Count", $array720count)
MsgBox(1, "1080 Count", $array1080count)
MsgBox(1, "Total Count", $totalcount)
DirCreate(@ScriptDir&"\Torrents")
DirCreate(@ScriptDir&"\Torrents\720")
DirCreate(@ScriptDir&"\Torrents\1080")
DownloadT($Array1080p,"1080")
DownloadT($download720, "720")


   




;MsgBox(1,"test","you are here")
;_ArrayDisplay($trythis)
;DirCreate(@ScriptDir&"\Torrents")
;DownloadT($trythis)

Func parsedCreate($webArray,$qual)
For $g = 1 to $webArray[1][0]
local $grabdata = Grabwebdata($sDomain,$sPage,$qual,$g)
;_ArrayDisplay($pulldata)
If $g = 1 Then
Local $pulldata = ReadwebData($grabdata)
;_ArrayDisplay($pulldata)
_ArrayDelete($pulldata, 0)
_ArrayDelete($pulldata, 0)
_ArrayDelete($pulldata, 0)
_ArrayDelete($pulldata, 0)
EndIf
If $g > 1 Then
Local $pulldata1 = ReadwebData($grabdata)
_ArrayDelete($pulldata1, 0)
_ArrayDelete($pulldata1, 0)
_ArrayDelete($pulldata1, 0)
_ArrayDelete($pulldata1, 0)
_ArrayCombineEX($pulldata, $pulldata1)
;_ArrayDisplay($pulldata)
EndIf
Next
;_ArrayDisplay($pulldata)
Return $pulldata
EndFunc



Func DownloadT($aArrayT,$local)
For $h = 0 to UBound($aArrayT) - 1
  Local $torrent = StringRegExp($aArrayT[$h][1], "start/(.*).torrent",1)
  ;local $downloadtorrent = GrabTorrent($sDomain, "/download/start",$torrent[0])
  InetGet($aArrayT[$h][1],@ScriptDir&"\Torrents\"&$local&"\"&$torrent[0]&".torrent")
  ;FileWrite(@ScriptDir&"\"&$torrent[0]&".torrent",$downloadtorrent)	
   ConsoleWrite($aArrayT[$h][1] & @CRLF)
Next
Return
EndFunc


;_ArrayDisplay($pulldata)



;Filter Returned Data

Func GrabTorrent($vsDomain,$vsPage,$vtorrentlocal)
   Local $hOpen = _WinHttpOpen("Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6") ;sets the browser varible. Initiate and get handle ID
   Local $hConnect = _WinHttpConnect($hOpen, $vsDomain) ; Connect to website
   Local $hRequest = _WinHttpOpenRequest($hConnect, "GET", $vsPage&"/"&$vtorrentlocal&".torrent") ; create request
   _WinHttpSendRequest($hRequest) ; send request
   _WinHttpReceiveResponse($hRequest) ; wait for response
   Local $sReturned
If _WinHttpQueryDataAvailable($hRequest) Then ; if there is data
    Do
       $sReturned &= _WinHttpReadData($hRequest) ; set returned variable
    Until @error
 EndIf
_WinHttpCloseHandle($hRequest)
_WinHttpCloseHandle($hConnect)
_WinHttpCloseHandle($hOpen)
Return $sReturned ; return
EndFunc


Func ReadwebData($vData)
   ;MsgBox(1,"test",$vData) ;Testing the varible is being passed correctly
   Local $vID = _XMLLoadXML($vData) ; load xml data to be sorted
  
   Local $nTitles = _XMLSelectNodes("/xml/MovieList/item") ;read the total movies returned pe page
   
   Local $tmovieCOUNT = _XMLGetValue("/xml/MovieCount"); read total 1080p movies avaible
   local $pRound = $tmovieCOUNT[1] / $nTitles[0] ; find page count
   local $pageCount = Ceiling($pRound); find true page count (round up to nearest whole number)
   local $vColum =  $nTitles[0] + 4 ; set colum length
   Local $returnARRAY[$vColum][2] ; build array to be returned via this function
   $returnARRAY[0][0] = $vColum ; Set total length of Array
   $returnARRAY[1][0] = $pageCount ; set total page count
   $returnARRAY[2][0] = $tmovieCOUNT[1] ; set total movie count
   $returnARRAY[3][0] = $nTitles[0] ; set movie count ~ per page
   
   For $i = 1 + 3 to $nTitles[0] + 3 ; For loop to pull out Titles and Torrent URL
	 local $titlenames = _XMLGetValue("/xml/MovieList/item["& $i - 3 &"]/MovieTitle") ; Pulls Title Names
	 local $torrentURL = _XMLGetValue("/xml/MovieList/item["& $i - 3 &"]/TorrentUrl") ; Pull Torrent URL
	 $returnARRAY[$i][0] = $titlenames[1] ; Populates titles in array
	 $returnARRAY[$i][1] = $torrentURL[1] ; Populates torrent in array
  Next ; end of For Loop
  return $returnARRAY ; Returns Array 
   EndFunc
   
; Function for interacting with api
Func Grabwebdata($vsDomain,$vsPage,$vQuality,$vSetCount)
   Local $hOpen = _WinHttpOpen("Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6") ;sets the browser varible. Initiate and get handle ID
   Local $hConnect = _WinHttpConnect($hOpen, $vsDomain) ; Connect to website
   Local $hRequest = _WinHttpOpenRequest($hConnect, "GET", $vsPage&"?quality="&$vQuality&"&set="&$vSetCount) ; create request
   _WinHttpSendRequest($hRequest) ; send request
   _WinHttpReceiveResponse($hRequest) ; wait for response
   Local $sReturned
If _WinHttpQueryDataAvailable($hRequest) Then ; if there is data
    Do
       $sReturned &= _WinHttpReadData($hRequest) ; set returned variable
    Until @error
 EndIf
_WinHttpCloseHandle($hRequest)
_WinHttpCloseHandle($hConnect)
_WinHttpCloseHandle($hOpen)
 ;MsgBox(1,"test",$sReturned)
Return $sReturned ; return
EndFunc
; End function

Func _ArrayCombineEX(ByRef $array1,ByRef $array2) ; Function to combine 2D arrays
    For $i=0 To Ubound($array2,1)-1
        ReDim $array1[Ubound($array1,1)+1][2]
        $array1[Ubound($array1,1)-1][0]=$array2[$i][0]
        $array1[Ubound($array1,1)-1][1]=$array2[$i][1]
    Next
EndFunc
