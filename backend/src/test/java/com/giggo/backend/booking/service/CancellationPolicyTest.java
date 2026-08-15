package com.giggo.backend.booking.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.giggo.backend.booking.domain.JobStatus;

@DisplayName("CancellationPolicy")
class CancellationPolicyTest {

    @Test
    @DisplayName("cancellable up to and including en route")
    void cancellableBeforeStart() {
        assertThat(CancellationPolicy.canCancel(JobStatus.REQUESTED)).isTrue();
        assertThat(CancellationPolicy.canCancel(JobStatus.ACCEPTED)).isTrue();
        assertThat(CancellationPolicy.canCancel(JobStatus.EN_ROUTE)).isTrue();
    }

    @Test
    @DisplayName("not cancellable once work has started or later")
    void notCancellableAfterStart() {
        assertThat(CancellationPolicy.canCancel(JobStatus.STARTED)).isFalse();
        assertThat(CancellationPolicy.canCancel(JobStatus.COMPLETED)).isFalse();
        assertThat(CancellationPolicy.canCancel(JobStatus.PAID)).isFalse();
        assertThat(CancellationPolicy.canCancel(JobStatus.CANCELLED)).isFalse();
    }

    @Test
    @DisplayName("gives a clear reason when blocked")
    void blockedReasonIsHelpful() {
        assertThat(CancellationPolicy.blockedReason(JobStatus.STARTED))
                .contains("already started");
    }
}
