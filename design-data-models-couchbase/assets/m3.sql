
###################################################
########################## Loading Data into a Bucket
###################################################

CREATE PRIMARY INDEX ON `loony-bank`;

INSERT INTO `loony-bank` (KEY, VALUE)
VALUES ("cust_1", {
				"name": "Bastian",
				"score": 8,
				"email": "bastian@bvsrao",
				"nomineeName": "Ana",
				"nomineeEmail": "ana@bvsrao",
				"type": "customer",
				"version": 1.0
			}
		);

INSERT INTO `loony-bank` (KEY, VALUE)
VALUES ("cust_2", {
				"name": "Sara",
				"score": 7 ,
				"email": "sara@bvsrao",
				"nominee": {
					"name": "Hella",
					"email:": "hella@bvsrao"
				},
				"type": "customer",
				"version": 1.4
			}
		),
		("cust_3", {
				"name": "Cosmin",
				"score": 7,
				"email": "cosmo@bvsrao",
				"nominee": {
					"name": "adi",
					"email:": "adi@bvsrao"
				},
				"type": "customer",
				"version": 1.4
			}
		),
		("cust_4", {
				"name": "Maria",
				"score": 9,
				"email": "maria@bvsrao",
				"phone": "555-9844",
				"nominees": [{
								 "name": "Ivo",
								 "email:": "ivo@bvsrao"
							 },
							 {
								 "name": "Morris",
								 "email:": "morris@bvsrao"
							 }
				],
				"type": "customer",
				"version": 2.0
			}
		),
		("cust_5", {
				"name": "Moctar",
				"score": 8,
				"email": "moctar@bvsrao",
				"phone": "555-0099",
				"nominees": [{
								 "name": "Aicha",
								 "email:": "Aicha@bvsrao"
							 },
							 {
								 "name": "Amrin",
								 "email:": "amrin@bvsrao"
							 },
							 {
								 "name": "Omar",
								 "email:": "Omar@bvsrao"
							 }
				],
				"type": "customer",
				"version": 2.0
			}
		);

SELECT name, type 
FROM `loony-bank`;

INSERT INTO `loony-bank` (KEY, VALUE)
VALUES ("acct_11", {
				"balance": 10000,
				"owner": "cust_1",
				"type": "account"
			}
		),
		("acct_24", {
				"balance": 7000,
				"owner": "cust_1",
				"type": "account"
			}
		),
		("acct_45", {
				"balance": 20000,
				"owner": "cust_3",
				"type": "account"
			}
		),
		("acct_17", {
				"balance": 1000,
				"owner": "cust_3",
				"type": "account"
			}
		),
		("acct_19", {
				"balance": 9000,
				"owner": "cust_4",
				"type": "account"
			}
		);

SELECT meta().id, balance, type 
FROM `loony-bank`
WHERE type = "account";


###################################################
######################## JOIN, NEST, and UNNEST Operations
###################################################

CREATE INDEX acct_owner ON `loony-bank`(owner)
WHERE type = "account";

SELECT cust.name, meta(acct).id, acct.balance
FROM `loony-bank` cust JOIN `loony-bank` acct
ON acct.owner = meta(cust).id
WHERE cust.type = "customer" 
AND acct.type = "account";

SELECT *
FROM `loony-bank` cust NEST `loony-bank` acct
ON acct.owner = meta(cust).id
AND acct.type = "account"
WHERE cust.type = "customer" ;

SELECT cust.name, acct[*].balance as acct_balances
FROM `loony-bank` cust NEST `loony-bank` acct
ON acct.owner = meta(cust).id
AND acct.type = "account"
WHERE cust.type = "customer" ;

SELECT cust.name, ARRAY_SUM(acct[*].balance) as total_balance
FROM `loony-bank` cust NEST `loony-bank` acct
ON acct.owner = meta(cust).id
AND acct.type = "account"
WHERE cust.type = "customer" ;

SELECT cust.name, acct[*].balance as acct_balances
FROM `loony-bank` cust LEFT NEST `loony-bank` acct
ON acct.owner = meta(cust).id
AND acct.type = "account"
WHERE cust.type = "customer" ;

SELECT cust.name, acct[*].balance as acct_balances
FROM `loony-bank` cust RIGHT NEST `loony-bank` acct
ON acct.owner = meta(cust).id
AND acct.type = "account"
WHERE cust.type = "customer" ;


## UNNEST

SELECT *
FROM `loony-bank`
WHERE type = "customer" ;

SELECT *
FROM `loony-bank` cust UNNEST nominees as custNominee
WHERE cust.type = "customer" ;

SELECT cust.name, cust.email, custNominee
FROM `loony-bank` cust UNNEST nominees as custNominee
WHERE cust.type = "customer" ;
