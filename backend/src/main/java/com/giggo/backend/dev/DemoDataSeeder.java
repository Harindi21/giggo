package com.giggo.backend.dev;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.giggo.backend.provider.domain.ProviderProfile;
import com.giggo.backend.provider.domain.Skill;
import com.giggo.backend.provider.repository.ProviderProfileRepository;
import com.giggo.backend.provider.repository.SkillRepository;
import com.giggo.backend.user.domain.User;
import com.giggo.backend.user.domain.UserRole;
import com.giggo.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

/**
 * Seeds demo providers (and one demo customer) for local showcase / manual testing.
 * DISABLED by default; enable with giggo.seed.demo-data=true (SEED_DEMO_DATA env).
 * Never enable in production — real providers self-register and complete KYC.
 * Idempotent: runs only when no provider profiles exist yet.
 */
@Component
@ConditionalOnProperty(name = "giggo.seed.demo-data", havingValue = "true")
@RequiredArgsConstructor
public class DemoDataSeeder implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DemoDataSeeder.class);
    private static final String DEMO_PASSWORD = "Provider@123";

    private final UserRepository userRepository;
    private final ProviderProfileRepository profileRepository;
    private final SkillRepository skillRepository;
    private final PasswordEncoder passwordEncoder;

    /** One demo provider row. */
    private record Seed(String fullName, String email, String headline, String district,
                        String addressLine, double lat, double lng,
                        String basePrice, String hourlyRate,
                        String avgRating, int ratingCount, int jobsCompleted,
                        boolean verified, List<String> skills) {}

    private static final List<Seed> PROVIDERS = List.of(
        new Seed("Supun Godage", "supun.godage@giggo.lk", "Experienced Plumber", "Colombo",
                "No. 9, Rose Rd, Col 6", 6.9271, 79.8612, "500", "500", "4.70", 128, 210, true,
                List.of("Plumbing", "Drilling & Fixing")),
        new Seed("Nishan Menaka", "nishan.menaka@giggo.lk", "Certified Electrician", "Dehiwala",
                "No. 1, BO Rd, Col 6", 6.8511, 79.8653, "600", "550", "4.50", 86, 140, true,
                List.of("Electrical Repairs", "Mounting & Installations")),
        new Seed("Akash Thaluduwa", "akash.thaluduwa@giggo.lk", "Skilled Carpenter", "Maharagama",
                "No. 30, Kanatte Rd, Col 5", 6.8480, 79.9265, "700", "600", "4.30", 54, 70, false,
                List.of("Carpentry")),
        new Seed("J.L. Mihil Senaka", "mihil.senaka@giggo.lk", "AC & Fridge Technician", "Colombo",
                "Main Road, Malabe", 6.9020, 79.9570, "800", "700", "4.80", 203, 260, true,
                List.of("AC & Refrigerator Repair", "Appliance Repair")),
        new Seed("Ashen Mihiranga", "ashen.mihiranga@giggo.lk", "Home Cleaning Pro", "Gampaha",
                "No. 12, Gold Rd, Col 6", 7.0917, 79.9997, "400", "350", "4.20", 41, 60, false,
                List.of("House Cleaning")),
        new Seed("Sihina Udeshaka", "sihina.udeshaka@giggo.lk", "Pest Control Specialist", "Negombo",
                "Sepalika Road, Col 5", 7.2083, 79.8358, "900", "500", "4.60", 77, 95, true,
                List.of("Pest Control")),
        new Seed("Senara Godage", "senara.godage@giggo.lk", "Reliable Plumber", "Kandy",
                "No. 9, Rose Rd, Kandy", 7.2906, 80.6337, "550", "500", "4.40", 33, 48, false,
                List.of("Plumbing")),
        new Seed("Ravindu Perera", "ravindu.perera@giggo.lk", "Appliance Repair Tech", "Colombo",
                "No. 45, Lake Rd, Col 8", 6.9350, 79.8610, "500", "450", "4.10", 22, 30, false,
                List.of("Appliance Repair")),
        new Seed("Dinesh Fernando", "dinesh.fernando@giggo.lk", "Painter & Interior Finisher", "Dehiwala",
                "No. 7, Sea St, Dehiwala", 6.8400, 79.8650, "1000", "600", "4.00", 18, 25, false,
                List.of("Interior Decoration")),
        new Seed("Kasun Jayawardena", "kasun.jayawardena@giggo.lk", "Gardener & Landscaper", "Gampaha",
                "No. 22, Green Ln, Gampaha", 7.0900, 79.9990, "600", "400", "4.50", 60, 90, true,
                List.of("Gardening & Landscaping")),
        new Seed("Nadeesha Silva", "nadeesha.silva@giggo.lk", "Hair & Beauty Stylist", "Colombo",
                "No. 3, Flower Rd, Col 7", 6.9130, 79.8600, "1200", "800", "4.90", 150, 180, true,
                List.of("Hair & Beauty")),
        new Seed("Tharindu Bandara", "tharindu.bandara@giggo.lk", "IT Support Engineer", "Kandy",
                "No. 5, Hill St, Kandy", 7.2950, 80.6350, "800", "700", "4.60", 44, 55, false,
                List.of("IT Support")),
        new Seed("Malith Gunawardena", "malith.gunawardena@giggo.lk", "Vehicle Repair Mechanic", "Maharagama",
                "No. 88, High Level Rd", 6.8470, 79.9260, "1500", "900", "4.30", 70, 110, false,
                List.of("Vehicle Repair", "Tyre & Battery")),
        new Seed("Ishara Wickramasinghe", "ishara.w@giggo.lk", "Maths Home Tutor", "Colombo",
                "No. 14, School Ln, Col 4", 6.8900, 79.8570, "1000", "1000", "4.80", 95, 120, true,
                List.of("Home Tutoring")),
        new Seed("Chamara Rathnayake", "chamara.rathnayake@giggo.lk", "Handyman & Installer", "Gampaha",
                "No. 2, Market Rd, Gampaha", 7.0930, 80.0000, "450", "400", "4.20", 29, 40, false,
                List.of("Mounting & Installations", "Drilling & Fixing"))
    );

    @Override
    @Transactional
    public void run(String... args) {
        if (profileRepository.count() > 0) {
            log.info("Demo data seeder: provider profiles already present, skipping.");
            return;
        }

        Map<String, Skill> skillsByName = skillRepository.findAll().stream()
                .collect(Collectors.toMap(Skill::getName, Function.identity(), (a, b) -> a));
        if (skillsByName.isEmpty()) {
            log.warn("Demo data seeder: no skills found (taxonomy migration missing?), skipping.");
            return;
        }

        String hash = passwordEncoder.encode(DEMO_PASSWORD);

        // Demo customer for quick login during showcase.
        if (userRepository.findByEmail("demo.customer@giggo.lk").isEmpty()) {
            userRepository.save(User.builder()
                    .email("demo.customer@giggo.lk")
                    .fullName("Demo Customer")
                    .phone("0770000000")
                    .passwordHash(hash)
                    .role(UserRole.CUSTOMER)
                    .active(true)
                    .emailVerified(true)
                    .build());
        }

        int created = 0;
        for (Seed s : PROVIDERS) {
            if (userRepository.findByEmail(s.email()).isPresent()) continue;

            User user = userRepository.save(User.builder()
                    .email(s.email())
                    .fullName(s.fullName())
                    .passwordHash(hash)
                    .role(UserRole.PROVIDER)
                    .active(true)
                    .emailVerified(true)
                    .build());

            Set<Skill> skills = new HashSet<>();
            for (String name : s.skills()) {
                Skill sk = skillsByName.get(name);
                if (sk != null) skills.add(sk);
            }

            profileRepository.save(ProviderProfile.builder()
                    .user(user)
                    .headline(s.headline())
                    .bio(s.headline() + " with proven track record. Serving " + s.district() + " and nearby areas.")
                    .yearsExperience(Math.max(1, s.jobsCompleted() / 20))
                    .available(true)
                    .district(s.district())
                    .addressLine(s.addressLine())
                    .latitude(s.lat())
                    .longitude(s.lng())
                    .basePrice(new BigDecimal(s.basePrice()))
                    .hourlyRate(new BigDecimal(s.hourlyRate()))
                    .avgRating(new BigDecimal(s.avgRating()))
                    .ratingCount(s.ratingCount())
                    .jobsCompleted(s.jobsCompleted())
                    .verified(s.verified())
                    .skills(skills)
                    .build());
            created++;
        }
        log.info("Demo data seeder: created {} demo providers (password '{}').", created, DEMO_PASSWORD);
    }
}
