<!-- vim:set ft=markdown sts=4 ts=4 sw=4 expandtab: -->
Jim Breen's JMdict database
===========================

Conversion Style Sheets
-----------------------

JMdict_e project aims at providing at dictionary databases with Japanese as its
pivot language. The meta language of these databases is english. The project
home is at <http://www.edrdg.org/jmdict/edict_doc.html>.

Copyright holders are: James William BREEN and The Electronic Dictionary Research and Development Group  
Copyright information at: <http://www.edrdg.org/edrdg/licence.html>

Conversion Process
----------------

Four manual steps are required to build a dictionary and these are given as an
example for the jpn-deu dictionary (ToDo: automate):

1.  `xsltproc -o draft.tei -novalid jmdict2tei.xsl JMdict.xml`
2.  ToDo:Copy the header !
3.  Indent: `xmllint --format draft.tei > jpn-deu.tei`
4.  Check validity:
    -   unixoid: `xmllint --noout --valid jpn-deu.tei > /dev/null`
    -   Windows: `xmllint --noout --valid jpn-deu.tei > nul`

JMdict Internationalization
---------------------------

Please note the JMdict Internationalization effort by Transifex :
https://www.transifex.com/gnurou/jmdict-i18n/

And the scripts going with by GitHub :
https://github.com/Gnurou/jmdict-i18n

