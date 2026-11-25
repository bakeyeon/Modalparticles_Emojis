# Modalpartikeln': Can Sentiments Survive Translation with Emojis? 
This research was developed as a term paper for the MA course "The Meaning of Gestures" (WS 23/24), supervised by Prof. Jacopo Romoli. The study features original data from a survey I personally conducted and analyzed using R. I appreciate your understanding regarding its preliminary nature and welcome any inquiries or academic discussions related to this work.

- Author: Kai H. Park (Ms)
- Supervised by: Prof. Jacopo Romoli

## Abstract
This study investigates the use of emoticons for translating the emotional connotations conveyed by German modal particles into other languages. German modal particles play a crucial role in adding subtlety and expressive emojis to speech, posing challenges for non-German speakers in grasping nuanced meanings. The research aims to facilitate intercultural communication and advance multilingual translation by exploring the capacity of emojis to capture the emotional nuances inherent in modal particles. Through a survey involving proficient speakers of German and Korean, significant similarities were observed between the emotional scores associated with modal particles and expressive emojis. These findings underscore the potential of emojis in preserving emotional expressions across diverse linguistic contexts.

## Limitations
- Subjectivity of Survey Data: As the study relies on surveys of proficient language users, the data is inherently subject to individual interpretation and personal perception of emotional nuances.
- Small Sample Size and Robustness: With $N=35$ for Survey 1 and $N=112$ for Survey 2, the relatively small sample sizes may limit the statistical robustness and the generalizability of the findings to a broader population.
- Cross-Cultural and Linguistic Variables: Emotional perception is deeply tied to cultural background and language proficiency. These factors influence how both modal particles and emojis are interpreted, potentially limiting the universal applicability of the results.
- Contextual Ambiguity and Polysemy: Certain particles, such as ja or schon, can convey opposing sentiments (e.g., friendliness vs. annoyance) depending on the context. Assigning a fixed sentiment score to these particles involves a degree of arbitrary simplification of their pragmatic complexity.
- Syntactic Position and Pragmatic Variance: While it is standard linguistic practice to account for subtle shifts in meaning based on the exact position of an element within a sentence, this study did not strictly control for syntactic variables. Consequently, the findings may have inherent limitations in capturing the full range of pragmatic nuances associated with word order variations.

## Re-analysis Note (2026)
I later revisited the analysis of this term paper. The PDF and the original script are left as submitted; please read them together with these notes. All numbers below come from [`reanalysis.R`](reanalysis.R).

**What holds**
- Sentiment ratings differ clearly across the ten particles (cumulative link mixed model, LR = 218.3, df = 9, p < .001).
- For the six one-to-one particle/emoji pairs, *halt* and *eigentlich* show no clear difference from their emojis, while *eben*, *wirklich*, *ruhig* and *nun einmal* do (Holm-adjusted). No clear difference is not evidence of equivalence.

**Corrections**
- The adjustment for `imp` used the *ja* score instead of the *mal* score. Corrected, `imp` is 0.412 (reported: 0.787), the cosine similarity 0.743 (reported: 0.659) and the t-test p = .025 (reported: .017).
- Cosine similarity describes how similar two score profiles are and should not be read as a success rate.

**To be read as exploratory**
- The shifts of 0.9, 0.03 and 0.1 were chosen after seeing the results, and the score adjustment combines two different scales (sentiment and strength).
- Cultural background was coded as a number, and many tests were run without correction. For particles, the results depend on how groups are formed (*doch*: adjusted p = .024 with two groups, .13 with three). For emojis, only `kisscl` and `disa` remain, with 11 participants outside the Korean group.
- The fluency result for *ruhig* depends on two participants (r = .60 with them, .09 without).
- Each particle appears in only one sentence, so particle and sentence effects cannot be separated.
- The original script also contains a t-test on resampled German data. It is not reported in the paper and should be disregarded.

## Related Study & Projects 
- How Much Sentiment Can Be Carried by Modal Particles? (https://github.com/bakeyeon/modalparticles_sentiment_analysis)
- Sentiment Translator (https://github.com/bakeyeon/sentiment_translator)
- Medium Post - Can We Translate Our Sentiments? (https://medium.com/gopenai/can-we-translate-our-sentiments-140c55822ead?sharedUserId=kaiwritesornot)


## Acknowledgments
I would like to thank Prof. Jacopo Romoli and Dr. Yulia Zinova for providing the insightful lectures and the academic environment that inspired this research. Their courses were instrumental in shaping the foundational ideas. 

## Citation 
```
@misc{park_2024_24326143,
  author       = {Park, Kai},
  title        = {Modalpartikeln': Can Sentiments Survive
                   Translation with Emojis?
                  },
  month        = mar,
  year         = 2024,
  publisher    = {Zenodo},
  version      = {v1.0.0},
  doi          = {10.5281/zenodo.24326143},
  url          = {https://doi.org/10.5281/zenodo.24326143},
}
```
