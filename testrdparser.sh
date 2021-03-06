set -e

tempfoo=`basename $0`
rm -rf $TMPDIR/$tempfoo.*
OUTDIR=`mktemp -d -t ${tempfoo}`

./buildparser.sh
go build cmd/printparse/printparse.go

GOOD_FILES='classonefield classtwofields assignment dispatchnoargs comparisons-assoc staticdispatchnoargs dispatchonearg nestedblocks addedlet letnoinit classmethodonearg letinit assignseq unaryassociativity dispatcharglist whileexpressionblock ifexpressionblock letassociativity whileoneexpression letinitmultiplebindings letparens multipleattributes multipledispatches associativity+ associativity- associativity-times associativitydiv arithprecedence ifnested multipleatdispatches casemultiplebranch formallists nestedlet complex atoi'
BAD_FILES='emptyprogram classnoname emptymethodbody attrcapitalname baddispatch4 emptystaticdispatch baddispatch3 equalsassociativity baddispatch2 returntypebad classbadinherits lteassociativity whilenoloop extrasemicolonblock ifnothenbranch classbadname badblock ifnoelsebranch emptyassign firstbindingerrored secondbindingerrored firstclasserrored baddispatch1 badexprlist newbadtype while assigngetstype isvoidbadtype multiplemethoderrors multipleclasses casenoexpr badfeaturenames ifnofi badfeatures ifnoelse'

echo "---- GOOD INPUT ----"
for i in $GOOD_FILES
do
    echo "### $i"
    ./printparse -rd testdata/parse/$i.test > $OUTDIR/$i.test.out || true
    cmp -s testdata/parse/$i.test.out $OUTDIR/$i.test.out || diff -u testdata/parse/$i.test.out $OUTDIR/$i.test.out
done
echo "---- BAD INPUT ----"
for i in $BAD_FILES
do
    echo "### $i"
    ./printparse -rd testdata/parse/$i.test > $OUTDIR/$i.test.out && rc=$? || rc=$?
	if [ "$rc" -eq "0" ]
	then
		echo "FAIL: unexpected successful parse!"
		exit
	fi
	# Don't care about exact error messages
    # cmp -s testdata/parse/$i.test.out $OUTDIR/$i.test.out || diff -u testdata/parse/$i.test.out $OUTDIR/$i.test.out
done

echo 'SUCCESS!'
rm -r $OUTDIR
rm -f ./printparse
