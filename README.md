 |-------------------------------------------------|
 |_______                 ________       _____     |
 |  |    |                   |    |   I    |  \\   |
 |  |    |       /\\         |    |   I    |   \\  |
 |  |____|      /  \\        |____|   I    |    |  |
 |  |\\        /____\\       |        I    |    |  |
 |  | \\      /      \\      |        I    |    |  |
 |  |  \\    /        \\     |        I    |   /   |
 |  |   \\  /          \\    |        I    |__/    |
 |                                                 |
 | -Read Alignment and Analysis Pipeline-          |
 |_________________________________________________|
RAPID
=====

RAPID is a set of tools for the alignment, and analysis of genomic regions with small RNA clusters derived from small RNA sequencing data.
It currently features:
- a module for individual dataset analysis and investigation using automated plots in R (rapid_main)
- a comparative module (rapid_compare) that can take as input several datasets processed with rapid_main. It normalizes read counts and produces a battery of comparative visualizations of the different datasets provided.
