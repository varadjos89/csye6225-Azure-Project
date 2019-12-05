
  sudo yum update

# Java-11 Installation and Path Setup
    sudo yum -y install java-11-openjdk-devel    
    echo "export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))" | sudo tee -a /etc/profile
    source /etc/profile
    echo "export PATH=$PATH:$JAVA_HOME/bin" | sudo tee -a /etc/profile
    echo "export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar" | sudo tee -a /etc/profile
    source /etc/profile
