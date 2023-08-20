function confmat(pred, truth)
    tp = sum(pred .& truth)
    tn = sum(.!pred .& .!truth)
    fp = sum(pred .& .!truth)
    fn = sum(.!pred .& truth)
    return [tp fn; fp tn]
end

acc(m) = tr(m)/sum(m)
tpr(m) = m[1,1]/(m[1,1]+m[1,2])
tnr(m) = m[2,2]/(m[2,2]+m[2,1])
fpr(m) = m[2,1]/(m[2,1]+m[2,2])
fnr(m) = m[1,2]/(m[1,2]+m[1,1])
ppv(m) = m[1,1]/(m[1,1]+m[2,1])
npv(m) = m[2,2]/(m[2,2]+m[1,2])
fone(m) = 2.0*(ppv(m)*tpr(m))/(ppv(m)+tpr(m))
inform(m) = tpr(m) + tnr(m) - 1.0
mcc(m) = ((m[1,1]*m[2,2])-(m[1,2]*m[2,1]))/sqrt((m[1,1]+m[2,1])*(m[1,1]+m[1,2])*(m[2,2]+m[2,1])*(m[2,2]+m[1,2]))