#MUST DOWNLOAD/INSTALL .NET CONNECTOR DRIVERS FOR MYSQL
[void][System.Reflection.Assembly]::LoadFrom('C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.25\Assemblies\v4.5.2\MySql.Data.dll')

Function Get-VaccineData{
    $myconnection = New-Object MySql.Data.MySqlClient.MySqlConnection
    $myconnection.ConnectionString = 'server=web-mysql-db.cwhlu8oxvtog.us-east-2.rds.amazonaws.com;port=3306;user id=admin;password=1qaz3edc!QAZ#EDC;database=WebDB;pooling=false'

    $mycommand = New-Object MySql.Data.MySqlClient.MySqlCommand
    $mycommand.Connection = $myconnection
    $mycommand.CommandText = 'SELECT FirstName,LastName FROM PERSONS'

    $CountFirstNames = $Null
    $CountLastNames = $Null

    $myconnection.open()
    $myreader = $mycommand.ExecuteReader()
    $DataTable = [System.Data.DataTable]::new()
    $DataTable.Load($myreader)

    $CountFirstNames = $DataTable[0].FirstName.Count
    $CountLastNames = $DataTable[0].LastName.Count
    Return $CountFirstNames, $CountLastNames

    $myconnection.Close()
    $myreader.Close()

}

#Your XAML goes here :)
$inputXML = @"
<Window x:Class="SQL_Query.MainWindow"
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:SQL_Query"
        mc:Ignorable="d"
        Title="MainWindow" Height="411" Width="433">
    <Grid Margin="0,0,0,2" RenderTransformOrigin="0.5,0.5">
        <Label Content="Number of Vaccines" HorizontalAlignment="Left" Height="29" Margin="29,149,0,0" VerticalAlignment="Top" Width="115"/>
        <Label Content="Number of People" HorizontalAlignment="Left" Height="29" Margin="29,183,0,0" VerticalAlignment="Top" Width="115"/>
        <Label Content="Vaccines Needed/Available" HorizontalAlignment="Left" Height="29" Margin="29,217,0,0" VerticalAlignment="Top" Width="152"/>
        <Label x:Name="Vaccines" Content="" HorizontalAlignment="Left" Height="29" Margin="203,149,0,0" VerticalAlignment="Top" Width="158"/>
        <Label x:Name="People" Content="" HorizontalAlignment="Left" Height="31" Margin="203,0,0,0" VerticalAlignment="Center" Width="158"/>
        <Label x:Name="NeedAvailable" Content="" HorizontalAlignment="Left" Height="29" Margin="203,217,0,0" VerticalAlignment="Top" Width="164"/>

    </Grid>
</Window>
"@ 
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{"trying item $($_.Name)";
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
# Use this space to add code to the various form elements in your GUI
#===========================================================================

$FirstNames,$LastNames = Get-VaccineData
$WPFVaccines.Content = $FirstNames
$WPFPeople.Content = $LastNames
$WPFNeedAvailable.Content = $FirstNames
$Form.ShowDialog() | Out-Null

#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'


