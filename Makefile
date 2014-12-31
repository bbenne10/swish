# sw - suckless webframework - 2012 - MIT License - nibble <develsec.org>

DESTDIR?=/usr/local

all: sw.conf

sw.conf:
	cp sw.conf.def sw.conf

install:
	mkdir -p ${DESTDIR}/bin
	sed -e "s,/usr/bin/awk,`./whereis awk`,g" md2html.awk > ${DESTDIR}/bin/md2html.awk
	chmod +x ${DESTDIR}/bin/md2html.awk
	cp -f sw ${DESTDIR}/bin/sw
	chmod +x ${DESTDIR}/bin/sw

uninstall:
	rm ${DESTDIR}/bin/md2html.awk
	rm ${DESTDIR}/bin/sw
