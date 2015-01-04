# sw - suckless webframework - 2012 - MIT License - nibble <develsec.org>

DESTDIR?=/usr/local

all: sw.conf

sw.conf:
	cp sw.conf.def sw.conf

install:
	mkdir -p ${DESTDIR}/bin
	cp -f sw ${DESTDIR}/bin/sw
	chmod +x ${DESTDIR}/bin/sw

uninstall:
	rm ${DESTDIR}/bin/sw
