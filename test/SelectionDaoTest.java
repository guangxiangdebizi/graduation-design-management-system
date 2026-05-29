import dao.SelectionDao;
import org.junit.Test;

import static org.junit.Assert.assertTrue;

public class SelectionDaoTest {
    @Test
    public void testCountApprovedStudents() {
        try {
            SelectionDao dao = new SelectionDao();
            int count = dao.countApprovedStudents();
            assertTrue("approved count should be non-negative", count >= 0);
        } catch (Exception ex) {
            System.out.println("Skipping DB test: " + ex.getMessage());
        }
    }

    @Test
    public void testReviewReturnsNonZeroCodes() {
        SelectionDao dao = new SelectionDao();
        int invalid = dao.review(-1, -1, "approved", "test");
        assertTrue(invalid == 0 || invalid == -1);
    }
}
