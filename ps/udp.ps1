# UDP server details
$ServerAddress = "time.cloudflare.com"   # Replace with the IP address of the UDP server
$ServerPort = 123            # Replace with the port number of the UDP server

# Message to send
$Message = "Hello, UDP Server!"

# Convert the message to bytes
$MessageBytes = [System.Text.Encoding]::UTF8.GetBytes($Message)

# Create a UDP client
$UDPClient = New-Object System.Net.Sockets.UdpClient

try {
    # Send the message to the UDP server
    $UDPClient.Send($MessageBytes, $MessageBytes.Length, $ServerAddress, $ServerPort)
    Write-Output "Sent message: $Message"

    # Set a timeout for receiving the response (in milliseconds)
    $UDPClient.Client.ReceiveTimeout = 3000

    # Receive response from the server
    $RemoteEndPoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Any, 0)
    $ResponseBytes = $UDPClient.Receive([ref]$RemoteEndPoint)

    # Convert the response to a string
    $ResponseMessage = [System.Text.Encoding]::UTF8.GetString($ResponseBytes)
    Write-Output "Received response: $ResponseMessage"
}
catch {
    Write-Output "An error occurred: $_"
}
finally {
    # Close the UDP client
    $UDPClient.Close()
}
