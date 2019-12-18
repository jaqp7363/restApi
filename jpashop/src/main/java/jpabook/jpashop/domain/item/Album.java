package jpabook.jpashop.domain.item;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

import lombok.Data;

@Entity
@DiscriminatorValue("A")
@Data
public class Album extends Item {

	private String artist;
	private String etc;
}
