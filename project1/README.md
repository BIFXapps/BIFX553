BIFX 553 Project I
===================

Schedule
--------

- Jan 26: Project overview and team proposals due
- Feb 2: DAG for clinical model done
- Feb 16: Begin analysis of clinical data 
- Feb 23: Begin analysis of GWAS data
- Mar 9: Project submissions due, Presentations
- Mar 18: Reviews due
- Mar 23: Response to Reviewers due


Data for Project 1
------------------

These data are simulated to mirror risk factors for HIV accquisition. They are from a simulated study looking at 4 world populations, with subpopulations specified:

- dat1: Africa (African Americans, West Africans and East Africans from Kenya)
- dat2: Men who have sex with men from Europe (Northern Europe and Italy)
- dat3: Women from Europe (Northern Europe and Italy)
- dat4: Asia (China, Japan and India)

Some of these subpopulations are quite a bit more different than others. You should take this into account in your analyses. These simulated data sets have actually been modelled after the HapMap3 collection and include sample IDs from the following groups:

- dat1: YRI, ASW, LWK, MKK
- dat2: CEU, TSI (male only)
- dat3: CEU, TSI (female only)
- dat4: CHB, JPT, GIH

The clinical data include several risk factors:

- multiple_partners: 1 = have multiple concurrent sexual partners
- known_partner_risk: 1 = individual knows partner's HIV status
- protected_sex: 0 = never uses protection, 1 = sometimes uses protection, 2 = always uses protection
- paid_sex: 1 = has received money or drugs for sex
- share_neeldes: 1 = has shared needles with other IV drug users (not present in all data sets)
- hiv: HIV status at study entry


Rubric
------

| Criterion | Components | Points |
|-----------|------------|--------|
| *Team effort* | | **40** |
|     | Balanced effort | 25 |
|     | Contributions documented | 15 |
| *Analysis* | | **60** |
|     | Neat repository | 10 |
|     | Readable code/comments | 10 |
|     | Assumptions checked | 10 |
|     | Statistical Model(s) | 10 | 
|     | Multiple comparisons | 10 |
|     | Results | 10 |
| *Manuscript* | | **60** |
|     | Fails plagerism check | -30 |
|     | Abstract | 10 |
|     | Introduction | 5 |
|     | Methods | 10 |
|     | Results | 10 | 
|     | Discussion | 10 |
|     | Conclusion | 10 |
|     | References | 5 |
| *Peer Review* | | **20** | 
|     | Conclusion | 5 |
|     | Major concerns | 15 |
|     | Minor concerns | 5 |
| *Response to Reviewers* | | **20** |
|     | Concerns addressed | 10 | 
|     | Justifications | 10 |
