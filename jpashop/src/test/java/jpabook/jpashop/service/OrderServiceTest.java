package jpabook.jpashop.service;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

import javax.persistence.EntityManager;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Transactional;

import jpabook.jpashop.domain.Address;
import jpabook.jpashop.domain.Member;
import jpabook.jpashop.domain.Order;
import jpabook.jpashop.domain.OrderStatus;
import jpabook.jpashop.domain.item.Book;
import jpabook.jpashop.domain.item.Item;
import jpabook.jpashop.exception.NotEnoughStockExceptioin;
import jpabook.jpashop.repository.OrderRepository;

@RunWith(SpringRunner.class)
@SpringBootTest
@Transactional
public class OrderServiceTest {

	@Autowired
	EntityManager em;
	
	@Autowired
	OrderService orderService;
	
	@Autowired
	OrderRepository orderRepository;
	
	@Test
	public void 상품주문() {
		Member member = new Member();
		member.setName("운둥이");
		member.setAddress(new Address("서울", "잠실", "123-123"));
		em.persist(member);
		
		Item book = new Book();
		book.setName("보험 자격증");
		book.setPrice(8000);
		book.setStockQuantity(7);
		em.persist(book);
		
		int orderCount = 2;
		
		Long orderId = orderService.order(member.getId(), book.getId(), orderCount);
		
		Order getOrder = orderRepository.findOne(orderId);
		
		assertEquals("상품 주문시 상태는 ORDER", OrderStatus.ORDER, getOrder.getStatus());
		assertEquals("주문한 상품 종류 수가 정확해야 한다.", 1, getOrder.getOrderItems().size());
		assertEquals("주문 가격은 가격 * 수량이다.", 8000 * 2, getOrder.getTotalPrice());
		assertEquals("주문 수량만큼 재고가 줄어야 한다.",5, book.getStockQuantity());
	}
	
	@Test
	public void 주문취소() throws Exception {
		Member member = createMember("테스팅");
		Book item = createItem("곧 취소", 500, 100);
		
		int orderCount = 2;
		
		Long orderId = orderService.order(member.getId(), item.getId(), orderCount);
		
		orderService.cancelOrder(orderId);
		
		Order order = orderRepository.findOne(orderId);
		assertEquals("주문 상태는 취소", OrderStatus.CANCEL, order.getStatus());
		assertEquals("item수량 원복", 100, item.getStockQuantity());
	}
	
	@Test(expected = NotEnoughStockExceptioin.class)
	public void 상품주문_재고수량초과() throws Exception {
		Member member = createMember("고운정");
		Item book = createItem("농업인의 삶", 5000, 2);
		
		int orderCount = 11;
		
		orderService.order(member.getId(), book.getId(), orderCount);
		
		fail("재고수량 부족");
	}

	public Member createMember(String name) {
		Member member = new Member();
		member.setName(name);
		member.setAddress(new Address("서울", "잠실", "123-123"));
		em.persist(member);
		return member;
	}
	
	public Book createItem(String name, int price, int qtt) {
		Book book = new Book();
		book.setName(name);
		book.setPrice(price);
		book.setStockQuantity(qtt);
		em.persist(book);
		return book;
	}
}
