#search for episode listing
#starting at the most recent
#generate the filename
#test if it already exists
#download to destination drive


[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null


$numAtEndRegex = ".*? - (?<episodeNum>\d+)$"
$numAtStartRegex = "Episode (?<episodeNum>\d+).*?"

$numAtStartRegex2 = "^(?<episodeNum>\d+) ?-.*?"
$epAtTheEnd = ".*? -? ?EP ?(?<episodeNum>\d+)$"


$episodeAtTheEnd = ".*? - EPISODE (?<episodeNum>\d+)$"

$episodeInLink = "http://traffic.libsyn.com/barbellshrugged/.*?(?<episodeNum>\d+).*?.mp3(?:\.m4a)?"


Write-Host "Downloading all Barbellshrugged"

$url = "http://barbellshrugged.libsyn.com/rss"
$client = new-object System.Net.WebClient
$episodeListings = [xml]$client.DownloadString($url)

$episodes = $episodeListings.SelectNodes("//item")

Write-Host "found " + $episodes.Count

#$response = Invoke-WebRequest -Uri "http://traffic.libsyn.com/barbellshrugged/BSE4itunes.mp3" -OutFile "test.mp3"


     $regex = new-object System.Text.RegularExpressions.Regex ($numAtEndRegex, [System.Text.RegularExpressions.RegexOptions]::MultiLine)
     $regex1 = new-object System.Text.RegularExpressions.Regex ($numAtStartRegex, [System.Text.RegularExpressions.RegexOptions]::MultiLine)
     $regex2 = new-object System.Text.RegularExpressions.Regex ($numAtStartRegex2, [System.Text.RegularExpressions.RegexOptions]::MultiLine)
     $regex3 = new-object System.Text.RegularExpressions.Regex ($epAtTheEnd, [System.Text.RegularExpressions.RegexOptions]::MultiLine)
     $regex4 = new-object System.Text.RegularExpressions.Regex ($episodeAtTheEnd, [System.Text.RegularExpressions.RegexOptions]::MultiLine)
     $regex5 = new-object System.Text.RegularExpressions.Regex ($episodeInLink, [System.Text.RegularExpressions.RegexOptions]::MultiLine)



Write-Host $response
foreach ($episode in $episodes)
{
    $episodeName = $episode.SelectSingleNode('title').'#text'
     $temp = $episode.SelectSingleNode('enclosure') | select url
     Write-Host $episodeName
     #Write-Host $temp.url
     
     $match = $regex.Match($episodeName)

     if ($match.Success)
     {
        $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
        $fepNum = "{0:D3}" -f $epNum
        Write-Host $fepNum
        $outputName = "e:\bbs\" + $fepNum + " - " + $episodeName + ".mp3"
        $response = Invoke-WebRequest -Uri $temp.url -OutFile $outputName

        continue;
     }

     $match = $regex1.Match($episodeName)
     
     if ($match.Success)
     {
        $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
        $fepNum = "{0:D3}" -f $epNum
        Write-Host $fepNum
         $outputName = "e:\bbs\" + $fepNum + " - " + $episodeName + ".mp3"
        $response = Invoke-WebRequest -Uri $temp.url -OutFile $outputName
        continue;
     }
     
     $match = $regex2.Match($episodeName)
     
     if ($match.Success)
     {
         $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
        $fepNum = "{0:D3}" -f $epNum
        Write-Host $fepNum
         $outputName = "e:\bbs\" + $fepNum + " - " + $episodeName + ".mp3"
        $response = Invoke-WebRequest -Uri $temp.url -OutFile $outputName
        continue;
     }
     
     $match = $regex3.Match($episodeName)
     
     if ($match.Success)
     {
         $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
        $fepNum = "{0:D3}" -f $epNum
        Write-Host $fepNum
         $outputName = "e:\bbs\" + $fepNum + " - " + $episodeName + ".mp3"
        $response = Invoke-WebRequest -Uri $temp.url -OutFile $outputName
        continue;
     }
     
     $match = $regex4.Match($episodeName)
     
     if ($match.Success)
     {
        $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
        $fepNum = "{0:D3}" -f $epNum
        Write-Host $fepNum
         $outputName = "e:\bbs\" + $fepNum + " - " + $episodeName + ".mp3"
        $response = Invoke-WebRequest -Uri $temp.url -OutFile $outputName
        continue;
     }
     
     
     $match = $regex5.Match($temp.url)
     
     if ($match.Success)
     {
         $epNum =  [convert]::ToInt32($match.Groups["episodeNum"], 10)
        $fepNum = "{0:D3}" -f $epNum
        Write-Host $fepNum
         $outputName = "e:\bbs\" + $fepNum + " - " + $episodeName + ".mp3"
        $response = Invoke-WebRequest -Uri $temp.url -OutFile $outputName
        continue;
     }
}


$strRawEpisodeName = "Aerobic Training for CrossFit: How to Improve Pacing, Breathing &amp; Recovery - 204"

$Decode = $strRawEpisodeName.Replace("&amp;", "&")

$strEpisodeNumber = $Decode.Substring($Decode.Length - 3)
$strEpisodeTitle = $Decode.Remove($Decode.Length - 5);

$strNewTitle = $strEpisodeNumber +  " - " + $strEpisodeTitle

Write-Host $strEpisodeNumber
Write-Host $strEpisodeTitle
Write-Host $strNewTitle