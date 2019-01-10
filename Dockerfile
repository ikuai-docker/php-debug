FROM ubuntu:18.10

################################
# 编译依赖
RUN apt-get update && \
	apt-get install -y \
	build-essential autoconf automake libtool re2c wget git gdb && \
	rm -rf /var/lib/apt/lists/*

################################
# bison
ENV BISON_VERSION 3.2.4

RUN cd /tmp && \
	wget http://ftp.gnu.org/gnu/bison/bison-$BISON_VERSION.tar.gz && \
	tar -xvf bison-$BISON_VERSION.tar.gz && \
	rm bison-$BISON_VERSION.tar.gz && \
	cd bison-$BISON_VERSION && \
	./configure --prefix=/opt/bison --with-libiconv-prefix=/opt/libiconv && \
	make && make install && \
	rm -rf /tmp/bison-$BISON_VERSION

ENV PATH "/opt/bison/bin:$PATH"

################################
# php, vld
RUN git clone https://github.com/derickr/vld.git /root/vld && \
	git clone https://github.com/php/php-src.git /root/php-src

ENV PHP_VERSION PHP-7.2.13
ENV PATH "/opt/php/bin:$PATH"

COPY .gdbinit /tmp/.gdbinit

RUN cd /root/php-src && \
	git checkout $PHP_VERSION && \
	./buildconf --force && \
	./configure --disable-all --enable-debug --prefix=/opt/php && \
	make && make install && \
	cp /root/php-src/.gdbinit /root/.gdbinit && \
	cat /tmp/.gdbinit >> /root/.gdbinit  && \
	cd /root/vld && \
	phpize && \
	./configure && \
	make && make install && \
	echo "extension=vld.so" >> /opt/php/lib/php.ini && \
	rm -rf /root/php-src && \
	rm -rf /root/vld

################################
# xdebug
ENV XDEBUG_VERSION 2.6.1

RUN cd /root && wget https://xdebug.org/files/xdebug-$XDEBUG_VERSION.tgz && \
	tar -xvzf xdebug-$XDEBUG_VERSION.tgz && \
	rm xdebug-$XDEBUG_VERSION.tgz && \
	cd xdebug-$XDEBUG_VERSION && \
	phpize && \
	./configure && \
	make && make install && \
	echo "zend_extension=xdebug.so" >> /opt/php/lib/php.ini && \
	rm -rf xdebug-$XDEBUG_VERSION

################################
# Clean
RUN apt-get purge -y --auto-remove build-essential autoconf automake libtool re2c \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /

CMD ["/bin/bash"]
