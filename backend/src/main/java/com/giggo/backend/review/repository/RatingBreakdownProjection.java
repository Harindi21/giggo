package com.giggo.backend.review.repository;

/** Per-dimension rating averages for a provider (P6.6). Averages are null when
 *  no visible review has scored that dimension. */
public interface RatingBreakdownProjection {
    Double getService();
    Double getPunctuality();
    Double getValueScore();
    long getTotal();
}
