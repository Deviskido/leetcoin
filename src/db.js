export const uid=()=>crypto.randomUUID();
export const now=()=>Date.now();
export function q(db,sql,...args){return db.prepare(sql).bind(...args);}
export async function one(db,sql,...args){return q(db,sql,...args).first();}
export async function rows(db,sql,...args){return (await q(db,sql,...args).all()).results;}
export function log(db,actor,action,entity,detail={}){return q(db,'INSERT INTO audit VALUES(?,?,?,?,?,?)',uid(),actor,action,entity,JSON.stringify(detail),now());}
export function entry(db,round,bet,kind,amount,ref){return q(db,'INSERT INTO ledger VALUES(?,?,?,?,?,?,?)',uid(),round,bet,kind,amount,ref,now());}
export async function atomic(db,round,statements){const id=uid();try{return await db.batch([q(db,'UPDATE rounds SET version=version+1 WHERE id=? AND version=?',round.id,round.version),q(db,'INSERT INTO cas_guard VALUES(?,changes())',id),...statements,q(db,'DELETE FROM cas_guard WHERE id=?',id)]);}catch(e){if(String(e).includes('ok=1'))throw Object.assign(Error('다른 요청이 먼저 반영되었습니다. 새로고침 후 다시 시도하세요.'),{status:409});throw e;}}
