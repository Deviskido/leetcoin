CREATE TABLE rounds (id TEXT PRIMARY KEY,title TEXT NOT NULL,source TEXT NOT NULL,closes INTEGER NOT NULL,status TEXT NOT NULL DEFAULT 'open' CHECK(status IN ('open','locked','settled','cancelled')),outcome TEXT CHECK(outcome IN ('A','B','cancel')),fee_bps INTEGER NOT NULL DEFAULT 500 CHECK(fee_bps=500),mode TEXT NOT NULL,version INTEGER NOT NULL DEFAULT 0,created INTEGER NOT NULL,settled INTEGER);
--> statement-breakpoint
CREATE TABLE bets (id TEXT PRIMARY KEY,round_id TEXT NOT NULL REFERENCES rounds(id),user_id TEXT NOT NULL,side TEXT NOT NULL CHECK(side IN ('A','B')),requested INTEGER NOT NULL CHECK(requested>0),received INTEGER NOT NULL DEFAULT 0 CHECK(received>=0),eligible INTEGER NOT NULL DEFAULT 0 CHECK(eligible IN(0,1)),status TEXT NOT NULL DEFAULT 'creating',invoice_id TEXT UNIQUE,checkout TEXT,address TEXT NOT NULL,created INTEGER NOT NULL,expires INTEGER NOT NULL,request_key TEXT NOT NULL,UNIQUE(user_id,request_key));
--> statement-breakpoint
CREATE TABLE deposits (id TEXT PRIMARY KEY,bet_id TEXT NOT NULL REFERENCES bets(id),txid TEXT NOT NULL,vout INTEGER NOT NULL,amount INTEGER NOT NULL CHECK(amount>0),seen INTEGER NOT NULL,created INTEGER NOT NULL,UNIQUE(txid,vout));
--> statement-breakpoint
CREATE TABLE payouts (id TEXT PRIMARY KEY,round_id TEXT NOT NULL REFERENCES rounds(id),bet_id TEXT NOT NULL REFERENCES bets(id),kind TEXT NOT NULL CHECK(kind IN('prize','refund')),amount INTEGER NOT NULL CHECK(amount>0),address TEXT NOT NULL,status TEXT NOT NULL DEFAULT 'due' CHECK(status IN('due','reserved','paid')),batch_id TEXT,txid TEXT,vout INTEGER,created INTEGER NOT NULL,UNIQUE(txid,vout));
--> statement-breakpoint
CREATE TABLE payout_batches (id TEXT PRIMARY KEY,round_id TEXT NOT NULL REFERENCES rounds(id),status TEXT NOT NULL DEFAULT 'prepared' CHECK(status IN('prepared','broadcast','paid')),txid TEXT UNIQUE,fee INTEGER CHECK(fee>=0),created INTEGER NOT NULL,confirmed INTEGER);
--> statement-breakpoint
CREATE TABLE ledger (id TEXT PRIMARY KEY,round_id TEXT NOT NULL REFERENCES rounds(id),bet_id TEXT,kind TEXT NOT NULL CHECK(kind IN('deposit','stake','operator_fee','prize_due','refund_due','payout_sent','network_fee')),amount INTEGER NOT NULL CHECK(amount>=0),reference TEXT NOT NULL UNIQUE,created INTEGER NOT NULL);
--> statement-breakpoint
CREATE TABLE audit (id TEXT PRIMARY KEY,actor TEXT NOT NULL,action TEXT NOT NULL,entity TEXT NOT NULL,detail TEXT NOT NULL,created INTEGER NOT NULL);
--> statement-breakpoint
CREATE TABLE cas_guard (id TEXT PRIMARY KEY,ok INTEGER NOT NULL CHECK(ok=1));
--> statement-breakpoint
CREATE INDEX bets_round ON bets(round_id);
--> statement-breakpoint
CREATE INDEX bets_user ON bets(user_id,created);
--> statement-breakpoint
CREATE INDEX payouts_round ON payouts(round_id,status);
--> statement-breakpoint
CREATE TRIGGER immutable_ledger_update BEFORE UPDATE ON ledger BEGIN SELECT RAISE(ABORT,'immutable ledger'); END;
--> statement-breakpoint
CREATE TRIGGER immutable_ledger_delete BEFORE DELETE ON ledger BEGIN SELECT RAISE(ABORT,'immutable ledger'); END;
--> statement-breakpoint
CREATE TRIGGER immutable_deposit_update BEFORE UPDATE ON deposits BEGIN SELECT RAISE(ABORT,'immutable deposit'); END;
--> statement-breakpoint
CREATE TRIGGER immutable_deposit_delete BEFORE DELETE ON deposits BEGIN SELECT RAISE(ABORT,'immutable deposit'); END;
