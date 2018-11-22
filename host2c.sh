export DEBIAN_FRONTEND=noninteractive
sudo su 
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce --assume-yes --force-yes
ip link set dev eth1 up
ip add add 192.168.252.2/30 dev eth1
ip route add 192.168.248.0/21 via 192.168.252.1

docker rm $(docker ps -a -q) #this command kills all containers if present, is useful if a user load the VM more than once.
docker run -dit --name SRwebserver -p 8080:80 -v /home/user/website/:/usr/local/apache2/htdocs/ httpd:2.4

echo "<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pagina web di Sergio e Riccardo</title>
</head>
<body>
    <h1 style='color: #5e9ca0;'>HI, THIS IS A DEMO WEBPAGE&nbsp;</h1>
    <h2 style='color: #2e6c80;'>Something silly:</h2>
        <p>  We apologize for our bad english, maybe in the md document you find strange the<br>    	     construction of some sentences, especially on the tenses. Anyway we hope that you read<br> 		     this few lines because, if so, it means that we did almost a right job guiding you<br> 	     through the process of creation of VM and retrieving this webpage from the webserver.<br> 	        Have a good day :) </p>
    <h2 style='color: #2e6c80;'>Creators:</h2>
	<p>- Riccardo Ricci -- 181398</p>
	<p>- Sergio Povoli -- 185790</p>
	<p><strong>&nbsp;</strong></p>   
</body>
</html>" > /home/user/website/index.html


