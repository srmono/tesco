
###################################################
########################## Expiring Documents with Bucket TTL
###################################################

## Apply a bucket TTL of 120s

## Existing documents are not affected

VALUES INSERT INTO `loony-bank` (KEY, VALUE)
VALUES ("acct_51", {
				"balance": 30000,
				"owner": "cust_5",
				"type": "account"
			}
		);

## Check metadata for the new account
## Wait for it to expire

SELECT name, email, meta().expiration
FROM `loony-bank`
WHERE meta().id = "cust_5";

UPDATE `loony-bank`
SET score = score+1
WHERE meta().id = "cust_5";

SELECT name, email, meta().expiration
FROM `loony-bank`
WHERE meta().id = "cust_5";

SELECT name, email, meta().expiration
FROM `loony-bank`
WHERE meta().id = "cust_2";


UPSERT INTO `loony-bank` (KEY, VALUE)
VALUES ("cust_2", {
				"name": "Sara",
				"score": 7 ,
				"email": "sara@bvsrao",
				"phone": "555-2288",
				"nominees": [{
					"name": "Hella",
					"email:": "hella@bvsrao"
				}],
				"type": "customer",
				"version": 2.0
			}
		);

SELECT name, email, meta().expiration
FROM `loony-bank`
WHERE meta().id = "cust_2";