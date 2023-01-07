# sw - suckless webframework - 2012 - MIT License - nibble <develsec.org>

DESTDIR?=/usr/local

all: sw.conf

sw.conf:
	cp swish.conf.def swish.conf

install:
	mkdir -p ${DESTDIR}/bin
	cp -f swi.sh ${DESTDIR}/bin/swi.sh
	chmod +x ${DESTDIR}/bin/swi.sh

uninstall:
	rm ${DESTDIR}/bin/sw
