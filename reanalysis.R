# Re-analysis of the Modalpartikeln / emoji surveys (2026)
# Setup: install.packages("ordinal")
# No duplicated participants; sentiment and strength questions kept apart; Holm correction throughout
library(ordinal)

if (!exists("DIR")) DIR <- "."  # folder with the two CSV files
na <- c("NA", "")
de <- read.csv(file.path(DIR, "Modalpartikeln.csv"), na.strings = na)
kr <- read.csv(file.path(DIR, "KoreanSurvey.csv"), na.strings = na, encoding = "UTF-8")
de$id <- sprintf("DE%03d", seq_len(nrow(de))); kr$id <- paste0("KR_", kr$nr)
single <- c("halt", "eben", "eigentlich", "wirklich", "mal", "ja", "ruhig", "nuneinmal", "doch", "schon")
pairs5 <- list(c("halt", "eben"), c("eigentlich", "wirklich"), c("mal", "ja"), c("ruhig", "nuneinmal"), c("doch", "schon"))
long <- function(d, cols, extra = NULL) data.frame(id = factor(rep(d$id, length(cols))), item = factor(rep(cols, each = nrow(d)), levels = cols),
  rating = unlist(d[cols], use.names = FALSE), d[rep(seq_len(nrow(d)), length(cols)), extra, drop = FALSE], row.names = NULL)
h <- function(t) cat("\n\n==== ", t, " ====\n", sep = "")
sgn <- function(x, mu = 3) suppressWarnings(wilcox.test(x, mu = mu, exact = FALSE)$p.value)
lrt <- function(a, b) { x <- 2 * as.numeric(logLik(b) - logLik(a)); k <- attr(logLik(b), "df") - attr(logLik(a), "df")
  cat(sprintf("  LR = %.1f, df = %d, p = %.3g
", x, as.integer(k), pchisq(x, k, lower.tail = FALSE))) }
bootci <- function(f, n = 4000) { set.seed(1); unname(quantile(replicate(n, f()), c(.025, .975))) }

h("A. German survey: sentiment of 10 single particles (1 negative, 3 neutral, 5 positive)")
L <- long(de, single); L$y <- ordered(L$rating)
m1 <- clmm(y ~ item + (1 | id), data = L); m0 <- clmm(y ~ 1 + (1 | id), data = L)
cat("Effect of particle (likelihood ratio test):\n"); lrt(m0, m1)
A <- do.call(rbind, lapply(single, function(s) { x <- de[[s]]; ci <- bootci(function() mean(sample(x, replace = TRUE)))
  data.frame(particle = s, mean = mean(x), lo = ci[1], hi = ci[2], p_vs3 = sgn(x)) }))
A$holm <- p.adjust(A$p_vs3, "holm"); A <- A[order(A$mean), ]
print(transform(A, mean = round(mean, 2), lo = round(lo, 2), hi = round(hi, 2), p_vs3 = signif(p_vs3, 2), holm = signif(holm, 2)), row.names = FALSE)
b <- c(0, m1$beta); names(b) <- single; V <- matrix(0, 10, 10); vv <- vcov(m1); nb <- length(m1$alpha) + seq_along(m1$beta); V[-1, -1] <- vv[nb, nb]
cmb <- combn(10, 2); P <- t(apply(cmb, 2, function(k) { e <- b[k[1]] - b[k[2]]; s <- sqrt(V[k[1], k[1]] + V[k[2], k[2]] - 2 * V[k[1], k[2]]); c(e, s, 2 * pnorm(-abs(e / s))) }))
PW <- data.frame(a = single[cmb[1, ]], b = single[cmb[2, ]], logodds = P[, 1], p = P[, 3], holm = p.adjust(P[, 3], "holm"))
cat("\nOf 45 pairwise comparisons, Holm p < .05:", sum(PW$holm < .05), "\nSentiment difference in the 5 pairs of the survey:\n")
for (q in pairs5) { r <- PW[PW$a == q[1] & PW$b == q[2], ]; cat(sprintf("  %-10s - %-10s logit difference %.2f, Holm p = %.3g\n", r$a, r$b, r$logodds, r$holm)) }

h("B. Assumption checks (approximate: clm without random effects)")
c1 <- clm(y ~ item, data = L)
print(scale_test(c1)); print(nominal_test(c1))
cat("Allowing a different spread per particle: AIC", round(AIC(c1), 1), "->", round(AIC(clm(y ~ item, scale = ~item, data = L)), 1), "\n")

h("C. German survey: pair questions ask about strength (1 much weaker, 3 no difference, 5 much stronger)")
C <- do.call(rbind, lapply(pairs5, function(q) { z <- de[[paste(q, collapse = "_")]]; dv <- de[[q[1]]] - de[[q[2]]]
  s <- suppressWarnings(cor.test(z, dv, method = "spearman", exact = FALSE))
  s2 <- suppressWarnings(cor.test(z, abs(de[[q[1]]] - 3) - abs(de[[q[2]]] - 3), method = "spearman", exact = FALSE))
  data.frame(pair = paste(q, collapse = " vs "), mean = round(mean(z), 2), p = sgn(z), rho_valence = round(s$estimate, 2), p_valence = signif(s$p.value, 2),
    rho_extremity = round(s2$estimate, 2), p_extremity = signif(s2$p.value, 2)) }))
C$holm <- signif(p.adjust(C$p, "holm"), 2); C$p <- signif(C$p, 2); print(C, row.names = FALSE)
cat("rho_valence: rank correlation of strength with the sentiment difference; rho_extremity: with the difference in distance from neutral\n")

h("D. Cultural background as categories (21 German vs 14 other)")
L2 <- long(de, single, "culturalbg"); L2$y <- ordered(L2$rating); L2$bg <- factor(ifelse(L2$culturalbg == "germany", "DE", "other"))
d1 <- clmm(y ~ item + bg + (1 | id), data = L2); d2 <- clmm(y ~ item * bg + (1 | id), data = L2)
lrt(d1, d2)
cp <- sapply(single, function(s) suppressWarnings(wilcox.test(de[[s]] ~ de$culturalbg == "germany", exact = FALSE)$p.value))
print(round(rbind(p = cp, holm = p.adjust(cp, "holm")), 3))

h("E. Fluency and ruhig: influence of two participants")
print(table(kenntnisse = de$kenntnisse))
f <- function(d) { r <- cor.test(d$ruhig, d$kenntnisse); sprintf("n = %d, r = %.2f, p = %.4f", nrow(d), r$estimate, r$p.value) }
cat("all:                      ", f(de), "\nwithout levels 1 and 2:  ", f(de[de$kenntnisse > 2, ]), "\n")

h("F. German particles vs Korean emojis (6 one-to-one pairs, no duplication)")
map <- c(halt = "conf", eben = "sweat", eigentlich = "broken", wirklich = "grim", ruhig = "kiss", nuneinmal = "twoh")
K <- kr[c("id", unname(map))]; names(K) <- c("id", names(map))
Z <- rbind(cbind(long(de, names(map)), lang = "DE"), cbind(long(K, names(map)), lang = "KR")); Z$lang <- factor(Z$lang); Z$y <- ordered(Z$rating)
cat("Participants: DE", nrow(de), ", KR", nrow(K), "/ missing:", sum(is.na(Z$rating)), "\n")
z0 <- clmm(y ~ item + lang + (1 | id), data = Z); z1 <- clmm(y ~ item * lang + (1 | id), data = Z)
cat("Does the language difference vary by item (item x lang):\n"); lrt(z0, z1)
R <- do.call(rbind, lapply(names(map), function(s) { x <- de[[s]]; y <- K[[s]]
  ci <- bootci(function() mean(sample(y, replace = TRUE)) - mean(sample(x, replace = TRUE)))
  data.frame(item = paste(s, map[s], sep = "/"), DE = mean(x), KR = mean(y), diff = mean(y) - mean(x), lo = ci[1], hi = ci[2],
    p = suppressWarnings(wilcox.test(x, y, exact = FALSE)$p.value)) }))
R$holm <- p.adjust(R$p, "holm"); R[2:6] <- round(R[2:6], 2); R$p <- signif(R$p, 2); R$holm <- signif(R$holm, 2); print(R, row.names = FALSE)

# For reference: effect of the old resampling of the German data (in the script, not reported in the paper)
h("G. For reference: Welch t-tests after resampling 35 participants to 112")
K2 <- kr[complete.cases(kr[setdiff(names(kr), "name_cult")]), ]
G <- do.call(rbind, lapply(names(map), function(s) { x <- de[[s]]; y <- K2[[map[s]]]; set.seed(1)
  p <- replicate(500, { i <- sample(35, 105, TRUE); t.test(x[c(i, sample(i, 7))], y)$p.value })
  data.frame(item = s, honest_p = signif(t.test(x, y)$p.value, 2), dup_median_p = signif(median(p), 2), dup_sig = mean(p < .05)) }))
print(G, row.names = FALSE); cat("dup_sig: share of 500 resamplings with p < .05\n")

h("H. Cultural background as categories, all 15 German items (Kruskal-Wallis, 3 groups)")
it <- c(single, sapply(pairs5, paste, collapse = "_"))
kw <- sapply(it, function(s) kruskal.test(de[[s]], factor(de$culturalbg))$p.value)
print(round(rbind(p = kw, holm = p.adjust(kw, "holm"))[, order(kw)][, 1:5], 3))

h("I. Korean survey: background and fluency, all 21 items (112 complete responses)")
items <- setdiff(names(kr), c("nr", "id", "fluency", "culturalbg", "name_cult", "gender", "age"))
k <- kr[complete.cases(kr[items]), ]; g <- k$culturalbg == "KR"
cat("background:", sum(g), "Korean,", sum(!g), "other; fluency:\n"); print(table(k$fluency))
p <- sapply(items, function(s) wilcox.test(k[[s]][g], k[[s]][!g], exact = FALSE)$p.value); hp <- p.adjust(p, "holm")
print(round(rbind(p, holm = hp)[, hp < .1, drop = FALSE], 4))
for (s in c("twoh", "kisscl", "sungl", "kissm", "fear")) { a <- cor.test(k[[s]], k$fluency); n <- k$fluency >= 4; b2 <- cor.test(k[[s]][n], k$fluency[n])
  cat(sprintf("  %-7s fluency r = %.2f (p = %.4f); levels 4-5 only: r = %.2f (p = %.3f, n = %d)\n", s, a$estimate, a$p.value, b2$estimate, b2$p.value, sum(n))) }

h("J. Reported score profiles: correcting the imp adjustment")
# values as reported in the paper, order: halt eben eigentlich wirklich ruhig nuneinmal mal+ ja+ doch+ schon+ mal- ja- doch- schon-
DE <- c(-.15714286, -.01428571, -.12142857, .19285714, .60714286, .63571429, .71473214, .87098214, .49206349, .15873016, -.50178571, -.12678571, .145, -.105)
KR <- c(.1965179, .2445536, .3946607, .2064464, .7662321, .8452321, .9600893, .8653036, .6573135, .6012659, .7866786, .1605357, .4638214, .3835357)
KR_raw <- c(.1986607, .2388393, .3950893, .2075893, .7700893, .8415179, .9553571, .7723214, .65625, .6205357, .3794643, .1473214, .4598214, .3705357)
cosine <- function(a, b) sum(a * b) / sqrt(sum(a^2) * sum(b^2))
KR2 <- KR; KR2[11] <- KR_raw[11] - (-.534 - DE[11])   # imp belongs to negative mal, the script used negative ja
cat(sprintf("imp: %.3f -> %.3f\n", KR[11], KR2[11]))
cat(sprintf("cosine: as reported %.3f, corrected %.3f, unadjusted Korean scores %.3f\n", cosine(DE, KR), cosine(DE, KR2), cosine(DE, KR_raw)))
cat(sprintf("Welch t-test p: as reported %.4f, corrected %.4f\n", t.test(DE, KR)$p.value, t.test(DE, KR2)$p.value))
