<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
	<sch:pattern>
		<sch:rule context="foo">
			<sch:assert test="false()" />
			<sch:report test="true()" />
		</sch:rule>
	</sch:pattern>
</sch:schema>
