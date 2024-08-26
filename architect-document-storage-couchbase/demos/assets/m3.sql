#############################################
############################## Bucket Configuration
#############################################

insert into `academic-data` (key, value)
values ("stu_01", { "student_id": 101,
                    "student_name": "Andrew",
                    "java_score": 40,
                    "python_score": 50,
                    "js_score": 60,
                    "fee_collected": 2200,
                    "wallet_balance": 780,
                    "date_of_pmt": "2012-07-30T23:58:22.193Z",
                    "other_scores": [
                                      {"arts": 10},
                                      {"history": 12},
                                      {"economics": 10}
                                     ],
                    "sports_medals": {
                                      "gold": 2,
                                      "bronze": 1
                    },
                    "dorm_fee":[300, 360, 380, 400, 350, 330]
                    }
        ),
        ("stu_02", {"student_id": 102,
                    "student_name": "David",
                    "java_score": 40,
                    "python_score": 60,
                    "js_score": 60,
                    "fee_collected": 2200,
                    "wallet_balance": 820,
                    "date_of_pmt": "2012-07-20T20:58:22.193Z",
                    "other_scores": [
                                     {"arts": 10},
                                     {"finance": 13},
                                     {"economics": 13}
                                    ],
                    "sports_medals": {
                                      "gold": 1,
                                      "silver": 1,
                                      "bronze": 1
                                      },
                    "dorm_fee":[340, 350, 300, 400, 300, 350]
                    }
        );

insert into `academic-data` (key, value)
values ("stu_03", { "student_id": 103,
                    "student_name": "Amy",
                    "java_score": 40,
                    "python_score": 80,
                    "js_score": 80,
                    "fee_collected": 2200,
                    "wallet_balance": 805,
                    "date_of_pmt": "2012-07-30T23:58:22.193Z",
                    "other_scores": [
                                     {"arts": 15},
                                     {"finance": 13},
                                     {"psychology": 10}
                                     ],
                    "sports_medals": {
                                     "bronze": 1
                                    },
                   "dorm_fee":[400, 350, 390, 400, 370, 350]
                }
        );

insert into `academic-data` (key, value)
values ("stu_04", { "student_id": 104,
                    "student_name": "Sarah",
                    "java_score": 60,
                    "python_score": 80,
                    "js_score": 90,
                    "fee_collected": 2200,
                    "wallet_balance": 770,
                    "date_of_pmt": "2012-07-25T03:58:22.193Z",
                    "other_scores": [
                                      {"arts": 12},
                                      {"history": 13},
                                      {"economics": 15}
                                    ],
                    "sports_medals": {
                                     "gold": 1,
                                     "silver": 3
                                    },
                    "dorm_fee":[300, 350, 350, 370, 300, 310]
                  }
       ),
       ("stu_05", { "student_id": 105,
                    "student_name": "Alice",
                    "java_score": 60,
                    "python_score": 80,
                    "js_score": 90,
                    "fee_collected": 2200,
                    "wallet_balance": 800,
                    "date_of_pmt": "2012-07-28T16:58:22.193Z",
                    "other_scores": [
                                      {"arts": 15},
                                      {"history": 12},
                                      {"economics": 10}
                                    ],
                    "sports_medals": {
                                      "gold": 3,
                                      "bronze": 2
                                   },
                    "dorm_fee":[390, 350, 370, 400, 380, 350]
                  }
       );