FROM registry.access.redhat.com/ubi7/ubi:7.7

ENV JBOSS_HOME=/opt/jboss

# Instal·lar utilitats, crear usuari, instal·lar Java i JBoss en UNA sola capa
RUN yum install -y unzip wget \
 && useradd jboss \
 && echo "jboss:$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)" | chpasswd \
 && usermod -aG wheel jboss \
 && yum install -y java-1.8.0-openjdk-headless \
 && yum clean all \
 && rm -rf /var/cache/yum \
 && mkdir -p /opt \
 && cd /opt \
 && unzip /tmp/jboss-eap-7.2.0.zip -d /opt \
 && mv /opt/jboss-eap-7.2 $JBOSS_HOME \
 && sed -i 's/^JAVA_OPTS="/JAVA_OPTS="$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0 /' $JBOSS_HOME/bin/standalone.conf \
 && $JBOSS_HOME/bin/add-user.sh admin admin123 --silent \
 && chown -R jboss:0 $JBOSS_HOME \
 && chmod -R g+rwX $JBOSS_HOME

# Copia prèvia del zip (ja descarregat al host)
COPY jboss-eap-7.2.0.zip /tmp/jboss-eap-7.2.0.zip

EXPOSE 8080 9090 9990

USER jboss

CMD ["/opt/jboss/bin/standalone.sh","-b","0.0.0.0","-bmanagement","0.0.0.0"]
