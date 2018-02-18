# GNU Makefile for the uniset package
# Markus Kuhn <http://www.cl.cam.ac.uk/~mgk25/>

.DELETE_ON_ERROR:

# Command to get source packages over the network
RETRIEVE=wget
REMOVECR=perl -p -i -e 's/\r$$//;'

# character set files loadable from various Internet servers

REMOTE_CHARFILES = UnicodeData.txt Blocks.txt EastAsianWidth.txt \
8859-1.TXT 8859-2.TXT 8859-3.TXT 8859-4.TXT 8859-5.TXT 8859-6.TXT \
8859-7.TXT 8859-8.TXT 8859-9.TXT 8859-10.TXT 8859-13.TXT 8859-14.TXT \
8859-15.TXT 8859-16.TXT \
CP1250.TXT CP1251.TXT CP1252.TXT CP1253.TXT CP1254.TXT CP1255.TXT \
CP1256.TXT CP1257.TXT CP1258.TXT \
CP437.TXT CP737.TXT CP775.TXT CP850.TXT CP852.TXT CP855.TXT CP857.TXT \
CP860.TXT CP861.TXT CP862.TXT CP863.TXT CP864.TXT CP865.TXT CP866.TXT \
CP869.TXT CP874.TXT \
CYRILLIC.TXT GREEK.TXT ICELAND.TXT LATIN2.TXT ROMAN.TXT TURKISH.TXT \
CP037.TXT CP1026.TXT CP500.TXT CP875.TXT \
NEXTSTEP.TXT IBMGRAPH.TXT \
SAMI CP437 CP850 \
stdenc.txt symbol.txt zdingbat.txt

GENERATED_CHARFILES = WGL4 MES-3A \
WIDTH-A WIDTH-F WIDTH-H WIDTH-N WIDTH-Na WIDTH-W \
X11-MINIMUM

# character set files original in this package

LOCAL_CHARFILES = MES-1 MES-2 MES-3B \
MES EES EES-COLLECTIONS MATH MATH-SMALL MIT VAUX VAUX-9 AUX WGL4 IPA-MINI \
IR-143.TXT IR-155.TXT IR-158.TXT IR-182.TXT DEC-VT100.TXT \
WIDTH-A WIDTH-F WIDTH-H WIDTH-N WIDTH-W \
8859-11.TXT TCVN6909 PS-MINIMUM EuroMHEG

UNISET_FILES = 00README uniset gen-wgl4 $(LOCAL_CHARFILES) \
	$(GENERATED_CHARFILES) $(REMOTE_CHARFILES)

all: $(UNISET_FILES)

distribution: $(UNISET_FILES)
	git diff --exit-code HEAD -- $(UNISET_FILES)
	tar cvf uniset.tar $(UNISET_FILES)
	gzip -9f uniset.tar
	mv uniset.tar.gz $(HOME)/.www/download/
	cp uniset $(HOME)/local/bin/

clean:
	rm -f *~ W.log core *.o

allclean: clean
	rm -f $(REMOTE_CHARFILES)

##########################################################################
#
# Repertoires that we regenerate by algorithm
#
##########################################################################


MES-3A: UnicodeData.txt
	echo "# MES-3A from CWA 13873:2000" >MES-3A
	echo "# http://www.evertype.com/standards/iso10646/pdf/cwa13873.pdf" >>MES-3A
	./uniset \
	+0020..007E +00A0..00FF +0100..017F +0180..024F +0250..02AF \
	+02B0..02FF +0300..036F +0370..03CF +03D0..03FF +0400..04FF \
	+0530..058F +10D0..10FF +1E00..1EFF +1F00..1FFF +2000..206F \
	+2070..209F +20A0..20CF +20D0..20FF +2100..214F +2150..218F \
	+2190..21FF +2200..22FF +2300..23FF +2440..245F +2500..257F \
	+2580..259F +25A0..25FF +2600..26FF +FB00..FB4F +FE20..FE2F \
	+FFF0..FFFD clean compact nr >>MES-3A

WGL4: UnicodeData.txt gen-wgl4
	./gen-wgl4 >$@

WIDTH-F: EastAsianWidth.txt
	echo "# UAX #11: EastAsianWidth Full-width" > $@
	perl -ne 'print "$$1\n" if /^([a-fA-F0-9\.]+);F\s*(\#.*)$$/;' < $< | \
	./uniset + - compact >> $@

WIDTH-H: EastAsianWidth.txt
	echo "# UAX #11: East Asian Half-width" > $@
	perl -ne 'print "$$1\n" if /^([a-fA-F0-9\.]+);H\s*(\#.*)$$/;' < $< | \
	./uniset + - compact >> $@

WIDTH-W: EastAsianWidth.txt
	echo "# UAX #11: East Asian Wide" > $@
	perl -ne 'print "$$1\n" if /^([a-fA-F0-9\.]+);W\s*(\#.*)$$/;' < $< | \
	./uniset + - compact >> $@

WIDTH-Na: EastAsianWidth.txt
	echo "# UAX #11: East Asian Narrow" > $@
	perl -ne 'print "$$1\n" if /^([a-fA-F0-9\.]+);Na\s*(\#.*)$$/;' < $< | \
	./uniset + - compact >> $@

WIDTH-N: EastAsianWidth.txt
	echo "# UAX #11: East Asian Neutral" > $@
	perl -ne 'print "$$1\n" if /^([a-fA-F0-9\.]+);N\s*(\#.*)$$/;' < $< | \
	./uniset + - compact >> $@

WIDTH-A: EastAsianWidth.txt
	echo "# UAX #11: East Asian Ambiguous" > $@
	perl -ne 'print "$$1\n" if /^([a-fA-F0-9\.]+);A\s*(\#.*)$$/;' < $< | \
	./uniset + - compact >> $@

X11-MINIMUM: WGL4
	echo "# Minimum repertoire of ANY *-ISO10646-1 X11 font" > $@
	echo "# (subset of WGL4, superset of CP1252 and" \
	"ISO 8859-{1-4,9,10,13,15}" >> $@
	./uniset + WGL4 -017F..FFFF \
	+ 8859-1.TXT + 8859-2.TXT + 8859-3.TXT + 8859-4.TXT \
	+ 8859-9.TXT + 8859-10.TXT + 8859-13.TXT + 8859-15.TXT + CP1252.TXT \
	compact nr >> $@

PS-MINIMUM:
	echo "# Minimum repertoire of any PostScript driver" > $@
	./uniset + ../font/adobe/75dpi/timR12.bdf + stdenc.txt + symbol.txt \
        +27e8-27e9 + CP1252.TXT clean ucs table nr >>$@

##########################################################################
#
# Places from where the packages can be retrieved
#
##########################################################################

CP437 CP850 SAMI KOI8-R:
	$(RETRIEVE) http://std.dkuug.dk/i18n/WG15-collection/charmaps/$@

CP1004 CP1252:
	$(RETRIEVE) http://wwwold.dkuug.dk/i18n/charmaps/$@

UnicodeData.txt Blocks.txt ReadMe.txt PropList.txt \
EastAsianWidth.txt UnicodeData.html Unihan.txt:
	$(RETRIEVE) http://www.unicode.org/Public/UNIDATA/$@

8859-1.TXT 8859-2.TXT 8859-3.TXT 8859-4.TXT 8859-5.TXT 8859-6.TXT \
8859-7.TXT 8859-8.TXT 8859-9.TXT 8859-10.TXT 8859-11.TXT 8859-13.TXT \
8859-14.TXT 8859-15.TXT 8859-16.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/ISO8859/$@
	$(REMOVECR) $@

CP1250.TXT CP1251.TXT CP1252.TXT CP1253.TXT CP1254.TXT CP1255.TXT \
CP1256.TXT CP1257.TXT CP1258.TXT CP932.TXT CP936.TXT CP949.TXT CP950.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/WINDOWS/$@

CP437.TXT CP737.TXT CP775.TXT CP850.TXT CP852.TXT CP855.TXT CP857.TXT \
CP860.TXT CP861.TXT CP862.TXT CP863.TXT CP864.TXT CP865.TXT CP866.TXT \
CP869.TXT CP874.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/PC/$@

CYRILLIC.TXT GREEK.TXT ICELAND.TXT LATIN2.TXT ROMAN.TXT TURKISH.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/MAC/$@

CP037.TXT CP1026.TXT CP500.TXT CP875.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/MICSFT/EBCDIC/$@

NEXTSTEP.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/NEXT/$@

stdenc.txt symbol.txt zdingbat.txt:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/ADOBE/$@

IBMGRAPH.TXT SGML.TXT KOI8-R.TXT CP1006.TXT CP424.TXT CP856.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/VENDORS/MISC/$@

JIS0201.TXT JIS0208.TXT JIS0212.TXT SHIFTJIS.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/JIS/$@

GB2312.TXT GB12345.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/GB/$@

CNS11643.TXT BIG5.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/OTHER/$@

KSX1001.TXT HANGUL.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/OBSOLETE/EASTASIA/KSC/$@

GSM0338.TXT:
	$(RETRIEVE) http://www.unicode.org/Public/MAPPINGS/ETSI/$@
