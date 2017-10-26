package org.testeditor.web.xtext.index.api

import com.fasterxml.jackson.databind.ObjectMapper
import io.dropwizard.jackson.Jackson
import org.junit.Test

import static org.assertj.core.api.Assertions.assertThat

import static extension io.dropwizard.testing.FixtureHelpers.*

class SayingTest {
	extension ObjectMapper MAPPER = Jackson.newObjectMapper

	@Test def void shouldSerializeToJSON() throws Exception {
		// given
		val saying = new Saying(42, "Arthur Dent")
		val expected = "fixtures/saying.json".fixture.readValue(Saying)
			.writeValueAsString

		// when
		val actual = saying.writeValueAsString

		// then
		assertThat(actual).isEqualTo(expected)
	}

	@Test def void shouldDeserializeFromJSON() throws Exception {
		//given
		val json = "fixtures/saying.json".fixture
		val expected = new Saying(42, "Arthur Dent")

		//when
		val actual = json.readValue(Saying)

		//then
		assertThat(actual.content).isEqualTo(expected.content)
	}

}
