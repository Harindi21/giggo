package com.giggo.backend.notification.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import com.giggo.backend.notification.service.NotificationService;
import com.giggo.backend.payment.event.PaymentCapturedEvent;

import lombok.RequiredArgsConstructor;

/**
 * Notifies a provider when a customer's payment is captured into escrow (P8).
 * Payment release into a settled booking is already announced via the booking's
 * PAID status change; this covers the earlier "funds secured" moment, which does
 * not move the booking's status. Fires after commit and fails soft.
 */
@Component
@RequiredArgsConstructor
public class PaymentNotificationListener {

    private static final Logger log = LoggerFactory.getLogger(PaymentNotificationListener.class);

    private final NotificationService notificationService;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPaymentCaptured(PaymentCapturedEvent event) {
        try {
            notificationService.notify(
                    event.providerId(),
                    "PAYMENT_HELD",
                    "Payment secured",
                    "The customer paid — funds are held safely in escrow for this job.",
                    event.bookingId());
        } catch (Exception ex) {
            log.warn("Could not notify provider {} of captured payment for booking {}: {}",
                    event.providerId(), event.bookingId(), ex.getMessage());
        }
    }
}
