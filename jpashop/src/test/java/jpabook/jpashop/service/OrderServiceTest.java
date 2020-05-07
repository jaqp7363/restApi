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
		member.setName("�����");
		member.setAddress(new Address("����", "���", "123-123"));
		em.persist(member);
		
		Item book = new Book();
		book.setName("���� �ڰ���");
		book.setPrice(8000);
		book.setStockQuantity(7);
		em.persist(book);
		
		int orderCount = 2;
		
		Long orderId = orderService.order(member.getId(), book.getId(), orderCount);
		
		Order getOrder = orderRepository.findOne(orderId);
		
		assertEquals("��ǰ �ֹ��� ���´� ORDER", OrderStatus.ORDER, getOrder.getStatus());
		assertEquals("�ֹ��� ��ǰ ���� ���� ��Ȯ�ؾ� �Ѵ�.", 1, getOrder.getOrderItems().size());
		assertEquals("�ֹ� ������ ���� * �����̴�.", 8000 * 2, getOrder.getTotalPrice());
		assertEquals("�ֹ� ������ŭ ��� �پ�� �Ѵ�.",5, book.getStockQuantity());
	}
	
	@Test
	public void 주문취소() throws Exception {
		Member member = createMember("�׽���");
		Book item = createItem("�� ���", 500, 100);
		
		int orderCount = 2;
		
		Long orderId = orderService.order(member.getId(), item.getId(), orderCount);
		
		orderService.cancelOrder(orderId);
		
		Order order = orderRepository.findOne(orderId);
		assertEquals("주문상태", OrderStatus.CANCEL, order.getStatus());
		assertEquals("주문수량", 100, item.getStockQuantity());
	}
	
	@Test(expected = NotEnoughStockExceptioin.class)
	public void 상품주문_재고수량초과() throws Exception {
		Member member = createMember("테스트");
		Item book = createItem("JPA 북", 5000, 2);
		
		int orderCount = 11;
		
		orderService.order(member.getId(), book.getId(), orderCount);
		
		fail("재고 수량 부족 예외가 발생해야 한다.");
	}

	public Member createMember(String name) {
		Member member = new Member();
		member.setName(name);
		member.setAddress(new Address("����", "���", "123-123"));
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
