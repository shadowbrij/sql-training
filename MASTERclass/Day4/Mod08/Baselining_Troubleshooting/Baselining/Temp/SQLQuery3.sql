--select * from dbo.MetricCategories
--select * from dbo.Metrics
select * from dbo.RecordedMetrics
--select * from servers
--select * from dbo.errors


select * from dbo.Metrics
where MetricName like '%lock%'

select * from dbo.RecordedMetrics
where MetricId = 79

select * from dbo.RecordedMetrics
where MetricId = 80

select * from dbo.RecordedMetrics
where MetricId = 77


select * from dbo.RecordedMetrics
where dateid = 89 and MetricId IN
(
68,
69,
70,
71,
72,
73,
74,
75,
76,
77,
78,
79,
80)