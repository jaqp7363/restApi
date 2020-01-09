package jpabook.jpashop.service;

import static org.junit.Assert.assertEquals;

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
	public void ��ǰ�ֹ�() {
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
	public void �ֹ����() throws Exception {
		
	}
	
	@Test
	public void ��ǰ�ֹ�_�������ʰ�() throws Exception {
		
	}

}
