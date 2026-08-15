package com.giggo.backend.notification.push;

import java.util.List;
import java.util.Map;

/**
 * Push delivery seam (P8.1). The default {@link StubPushSender} lets the whole
 * notification flow run without credentials. A real FCM adapter would implement
 * this same interface (using firebase-admin + a service-account key) and be
 * selected with {@code giggo.notifications.push-provider}.
 */
public interface PushSender {

    /** Provider id, e.g. "stub" or "fcm". */
    String name();

    /** Deliver a push to the given device tokens; must not throw. */
    void send(List<String> tokens, String title, String body, Map<String, String> data);
}
