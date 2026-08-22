package com.giggo.backend.user.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.giggo.backend.common.exception.ResourceNotFoundException;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
@DisplayName("AdminUserService")
class AdminUserServiceTest {

    @Mock UserRepository userRepository;

    private AdminUserService service;

    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new AdminUserService(userRepository);
        lenient().when(userRepository.save(any())).thenAnswer(i -> i.getArgument(0));
    }

    @Test
    @DisplayName("suspend disables the account; reactivate re-enables it")
    void suspendReactivate() {
        User user = User.builder().id(userId).active(true).build();
        when(userRepository.findById(userId)).thenReturn(Optional.of(user));

        assertThat(service.setActive(userId, false).isActive()).isFalse();
        assertThat(service.setActive(userId, true).isActive()).isTrue();
    }

    @Test
    @DisplayName("unknown user -> 404")
    void unknownUser() {
        when(userRepository.findById(userId)).thenReturn(Optional.empty());
        assertThatThrownBy(() -> service.setActive(userId, false))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
