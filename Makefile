parse-showfiles:
	tools/extractdata.pl -r

buildtree:
	tools/manage-buildtree.pl -a

.PHONY: parse-showfiles buildtree

