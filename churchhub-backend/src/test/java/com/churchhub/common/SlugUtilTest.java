package com.churchhub.common;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SlugUtilTest {

    @Test
    void stripsVietnameseDiacritics() {
        assertThat(SlugUtil.slugify("Nhà Thờ Chính Tòa")).isEqualTo("nha-tho-chinh-toa");
    }

    @Test
    void handlesDelChar() {
        assertThat(SlugUtil.slugify("Đức Mẹ Hằng Cứu Giúp")).isEqualTo("duc-me-hang-cuu-giup");
    }

    @Test
    void collapsesRunsOfWhitespaceIntoSingleDash() {
        assertThat(SlugUtil.slugify("Giáo   Xứ")).isEqualTo("giao-xu");
    }

    @Test
    void collapsesRunsOfDashesAndTrimsEdges() {
        assertThat(SlugUtil.slugify("---abc---")).isEqualTo("abc");
    }

    @Test
    void blankOrNullInputReturnsEmptyString() {
        assertThat(SlugUtil.slugify("   ")).isEmpty();
        assertThat(SlugUtil.slugify(null)).isEmpty();
    }
}
