sudo yum update -y
sudo yum -y install git
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo '# rbenv' >> ~/.bash_profile
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
sudo yum -y install bzip2 gcc gcc-c++ openssl-devel readline-devel zlib-devel mysql-devel tmux libxml2 libxml2-devel libcurl libcurl-devel
sudo yum -y --enablerepo=epel install redis
rbenv install -s 2.6.1
rbenv global 2.6.1
gem install bundler

sudo yum -y install nginx
sudo service nginx start
sudo service redis start

curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum -y install yarn

sudo chmod o+x /var/lib/nginx/
sudo chmod o+x /var/lib/nginx/tmp
sudo chmod o+x /var/lib/nginx/tmp/client_body

echo "alias nginx_restart='sudo nginx -s stop; sudo service nginx start'" >> ~/.bashrc
echo "alias nginx_access_log='sudo sh -c \"cd /var/log/nginx; tail -f access.log\"'" >> ~/.bashrc
echo "alias nginx_error_log='sudo sh -c \"cd /var/log/nginx; tail -f error.log\"'" >> ~/.bashrc
echo "alias ll='ls -la'" >> ~/.bashrc
