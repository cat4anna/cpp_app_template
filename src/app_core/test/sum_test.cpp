#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <app_core/sum.hpp>

namespace app {

class SumTest : public ::testing::Test {
protected:
    void SetUp() override {}
};

TEST_F(SumTest, doSum) {
    EXPECT_EQ(sum(1,1), 2);
}

} // namespace app